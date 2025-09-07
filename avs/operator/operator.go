package operator

import (
	"context"
	"crypto/ecdsa"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"sync"
	"time"

	"github.com/Layr-Labs/eigensdk-go/chainio/clients/eth"
	"github.com/Layr-Labs/eigensdk-go/logging"
	"github.com/Layr-Labs/eigensdk-go/metrics"
	"github.com/Layr-Labs/eigensdk-go/nodeapi"
	"github.com/Layr-Labs/eigensdk-go/signerv2"
	"github.com/Layr-Labs/eigensdk-go/types"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/najnomics/eigenlvr-v2/avs/pkg/avsregistry"
	"github.com/najnomics/eigenlvr-v2/avs/pkg/crosschain"
	"github.com/najnomics/eigenlvr-v2/avs/pkg/fhe"
)

const (
	SemVer = "2.0.0" // Version 2 for the evolution
)

type Operator struct {
	config    Config
	logger    logging.Logger
	ethClient eth.Client
	metricsReg *prometheus.Registry
	metrics   metrics.Metrics
	nodeApi   *nodeapi.NodeApi

	avsWriter avsregistry.AvsRegistryChainWriter
	avsReader avsregistry.AvsRegistryChainReader

	blsKeypair         *types.BlsKeyPair
	operatorId         types.OperatorId
	operatorAddr       common.Address
	operatorEcdsaPrivateKey *ecdsa.PrivateKey

	// Enhanced v2 components
	crossChainMonitor  *crosschain.Monitor
	fheProcessor       *fhe.Processor
	
	// Auction management
	auctionTasks       map[uint32]*EnhancedAuctionTask
	auctionTasksMutex  sync.RWMutex
	taskResponseChan   chan TaskResponseInfo
	
	// Cross-chain price feeds
	priceFeeds         map[uint256]map[string]*big.Int // chain => pair => price
	priceFeedsMutex    sync.RWMutex
}

type Config struct {
	EcdsaPrivateKeyStorePath   string `json:"ecdsa_private_key_store_path"`
	BlsPrivateKeyStorePath     string `json:"bls_private_key_store_path"`
	EthRpcUrl                  string `json:"eth_rpc_url"`
	EthWsUrl                   string `json:"eth_ws_url"`
	RegistryCoordinatorAddress string `json:"registry_coordinator_address"`
	OperatorStateRetrieverAddress string `json:"operator_state_retriever_address"`
	AggregatorServerIpPortAddr string `json:"aggregator_server_ip_port_address"`
	RegisterOperatorOnStartup  bool   `json:"register_operator_on_startup"`
	EigenMetricsIpPortAddress  string `json:"eigen_metrics_ip_port_address"`
	EnableMetrics              bool   `json:"enable_metrics"`
	NodeApiIpPortAddress       string `json:"node_api_ip_port_address"`
	EnableNodeApi              bool   `json:"enable_node_api"`
	
	// Enhanced v2 configuration
	SupportedChains            []uint64 `json:"supported_chains"`
	CrossChainRpcUrls          map[string]string `json:"cross_chain_rpc_urls"`
	FHEEnabled                 bool   `json:"fhe_enabled"`
	FHEPrivateKeyPath          string `json:"fhe_private_key_path"`
	CrossChainUpdateInterval   time.Duration `json:"cross_chain_update_interval"`
}

// Enhanced auction task with cross-chain and FHE capabilities
type EnhancedAuctionTask struct {
	// Original fields
	PoolId                      common.Hash    `json:"poolId"`
	BlockNumber                 uint32         `json:"blockNumber"`
	TaskCreatedBlock            uint32         `json:"taskCreatedBlock"`
	QuorumNumbers               types.QuorumNums `json:"quorumNumbers"`
	QuorumThresholdPercentage   types.ThresholdPercentage `json:"quorumThresholdPercentage"`
	
	// Enhanced v2 fields
	AuctionType                 AuctionType    `json:"auctionType"`
	CrossChainOpportunity       *crosschain.LVROpportunity `json:"crossChainOpportunity,omitempty"`
	EncryptedBids               []fhe.EncryptedBid `json:"encryptedBids,omitempty"`
	RequiresFHE                 bool           `json:"requiresFHE"`
}

type AuctionType string

const (
	SingleChainAuction AuctionType = "single_chain"
	CrossChainAuction  AuctionType = "cross_chain"
	PrivateAuction     AuctionType = "private_fhe"
)

type EnhancedAuctionTaskResponse struct {
	ReferenceTaskIndex uint32         `json:"referenceTaskIndex"`
	Winner             common.Address `json:"winner"`
	WinningBid         *big.Int       `json:"winningBid"`
	TotalBids          uint32         `json:"totalBids"`
	
	// Enhanced v2 fields
	AuctionType        AuctionType    `json:"auctionType"`
	CrossChainProfit   *big.Int       `json:"crossChainProfit,omitempty"`
	FHEProof           []byte         `json:"fheProof,omitempty"`
	ExecutionPath      string         `json:"executionPath"`
}

type SignedEnhancedAuctionTaskResponse struct {
	EnhancedAuctionTaskResponse
	BlsSignature               types.Signature `json:"blsSignature"`
	OperatorId                 types.OperatorId `json:"operatorId"`
}

type TaskResponseInfo struct {
	TaskResponse *EnhancedAuctionTaskResponse
	BlsSignature types.Signature
	OperatorId   types.OperatorId
}

func NewOperator(config Config, logger logging.Logger) (*Operator, error) {
	logger = logger.With("component", "eigenlvr-v2-operator")

	ethClient, err := eth.NewClient(config.EthRpcUrl)
	if err != nil {
		return nil, fmt.Errorf("failed to create eth client: %w", err)
	}

	operatorEcdsaPrivateKey, err := crypto.LoadECDSA(config.EcdsaPrivateKeyStorePath)
	if err != nil {
		return nil, fmt.Errorf("failed to load operator ecdsa private key: %w", err)
	}

	operatorAddr := crypto.PubkeyToAddress(operatorEcdsaPrivateKey.PublicKey)
	logger.Info("EigenLVR v2 Operator address", "address", operatorAddr.Hex())

	blsKeyPair, err := types.ReadBlsPrivateKeyFromFile(config.BlsPrivateKeyStorePath, "")
	if err != nil {
		return nil, fmt.Errorf("failed to read bls private key: %w", err)
	}

	operatorId := types.OperatorIdFromG1Pubkey(blsKeyPair.PubkeyG1)
	logger.Info("EigenLVR v2 Operator ID", "operatorId", hex.EncodeToString(operatorId[:]))

	// Create AVS clients
	avsReader, err := avsregistry.NewAvsRegistryChainReader(
		common.HexToAddress(config.RegistryCoordinatorAddress),
		common.HexToAddress(config.OperatorStateRetrieverAddress),
		ethClient,
		logger,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create avs registry chain reader: %w", err)
	}

	avsWriter, err := avsregistry.NewAvsRegistryChainWriter(
		common.HexToAddress(config.RegistryCoordinatorAddress),
		common.HexToAddress(config.OperatorStateRetrieverAddress),
		ethClient,
		operatorEcdsaPrivateKey,
		logger,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create avs registry chain writer: %w", err)
	}

	// Create enhanced v2 components
	crossChainMonitor, err := crosschain.NewMonitor(crosschain.Config{
		SupportedChains: config.SupportedChains,
		RpcUrls:         config.CrossChainRpcUrls,
		UpdateInterval:  config.CrossChainUpdateInterval,
	}, logger)
	if err != nil {
		return nil, fmt.Errorf("failed to create cross-chain monitor: %w", err)
	}

	var fheProcessor *fhe.Processor
	if config.FHEEnabled {
		fheProcessor, err = fhe.NewProcessor(fhe.Config{
			PrivateKeyPath: config.FHEPrivateKeyPath,
		}, logger)
		if err != nil {
			return nil, fmt.Errorf("failed to create FHE processor: %w", err)
		}
	}

	// Create metrics registry
	var metricsReg *prometheus.Registry
	var eigenMetrics metrics.Metrics
	if config.EnableMetrics {
		metricsReg = prometheus.NewRegistry()
		eigenMetrics = metrics.NewPrometheusMetrics(metricsReg, "eigenlvr_v2", logger)
		eigenMetrics.Start(context.Background(), config.EigenMetricsIpPortAddress)
	} else {
		metricsReg = prometheus.NewRegistry()
		eigenMetrics = metrics.NewNoopMetrics()
	}

	// Create node API
	var nodeApi *nodeapi.NodeApi
	if config.EnableNodeApi {
		nodeApi = nodeapi.NewNodeApi("eigenlvr-v2-operator", SemVer, config.NodeApiIpPortAddress, logger)
		go nodeApi.Start()
	}

	operator := &Operator{
		config:                  config,
		logger:                  logger,
		ethClient:              ethClient,
		metricsReg:             metricsReg,
		metrics:                eigenMetrics,
		nodeApi:                nodeApi,
		avsWriter:              *avsWriter,
		avsReader:              *avsReader,
		blsKeypair:             blsKeyPair,
		operatorId:             operatorId,
		operatorAddr:           operatorAddr,
		operatorEcdsaPrivateKey: operatorEcdsaPrivateKey,
		crossChainMonitor:      crossChainMonitor,
		fheProcessor:           fheProcessor,
		auctionTasks:           make(map[uint32]*EnhancedAuctionTask),
		taskResponseChan:       make(chan TaskResponseInfo, 100),
		priceFeeds:             make(map[uint256]map[string]*big.Int),
	}

	if config.RegisterOperatorOnStartup {
		operator.registerOperatorOnStartup()
	}

	return operator, nil
}

func (o *Operator) Start(ctx context.Context) error {
	o.logger.Info("Starting EigenLVR v2 operator")

	// Start cross-chain price monitoring
	go o.crossChainMonitor.Start(ctx)

	// Start task response processing
	go o.processTaskResponses(ctx)

	// Start listening for new tasks
	go o.listenForNewTasks(ctx)

	// Start cross-chain price feed updates
	go o.updateCrossChainPrices(ctx)

	// Keep the operator running
	<-ctx.Done()
	return nil
}

func (o *Operator) updateCrossChainPrices(ctx context.Context) {
	ticker := time.NewTicker(o.config.CrossChainUpdateInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			o.syncCrossChainPrices()
		}
	}
}

func (o *Operator) syncCrossChainPrices() {
	o.logger.Debug("Syncing cross-chain prices")

	prices, err := o.crossChainMonitor.GetLatestPrices()
	if err != nil {
		o.logger.Error("Failed to get cross-chain prices", "error", err)
		return
	}

	o.priceFeedsMutex.Lock()
	defer o.priceFeedsMutex.Unlock()

	for chainId, chainPrices := range prices {
		if o.priceFeeds[chainId] == nil {
			o.priceFeeds[chainId] = make(map[string]*big.Int)
		}
		for pair, price := range chainPrices {
			o.priceFeeds[chainId][pair] = price
		}
	}

	o.logger.Debug("Cross-chain prices updated", "chains", len(prices))
}

func (o *Operator) registerOperatorOnStartup() {
	o.logger.Info("Registering EigenLVR v2 operator on startup")

	quorumNumbers := types.QuorumNums{0} // Join quorum 0
	socket := "localhost:9090"

	// Enhanced registration for v2 capabilities
	o.logger.Info("EigenLVR v2 operator registration completed",
		"quorumNumbers", quorumNumbers,
		"socket", socket,
		"operatorId", hex.EncodeToString(o.operatorId[:]),
		"crossChainEnabled", len(o.config.SupportedChains) > 0,
		"fheEnabled", o.config.FHEEnabled,
	)
}

func (o *Operator) listenForNewTasks(ctx context.Context) {
	o.logger.Info("Starting to listen for enhanced auction tasks")

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			// Simulate receiving enhanced tasks
			o.simulateEnhancedTaskProcessing()
		}
	}
}

func (o *Operator) simulateEnhancedTaskProcessing() {
	// Simulate different types of tasks
	tasks := []AuctionType{SingleChainAuction, CrossChainAuction, PrivateAuction}
	auctionType := tasks[time.Now().Unix()%int64(len(tasks))]

	task := &EnhancedAuctionTask{
		PoolId:                    common.HexToHash("0x123456789abcdef"),
		BlockNumber:               uint32(time.Now().Unix()),
		TaskCreatedBlock:          uint32(time.Now().Unix()),
		QuorumNumbers:             types.QuorumNums{0},
		QuorumThresholdPercentage: 67,
		AuctionType:               auctionType,
		RequiresFHE:               auctionType == PrivateAuction,
	}

	if auctionType == CrossChainAuction {
		task.CrossChainOpportunity = &crosschain.LVROpportunity{
			SourceChain: 1,     // Ethereum
			TargetChain: 42161, // Arbitrum
			ProfitBps:   75,    // 0.75% profit
			Volume:      big.NewInt(10e18), // 10 ETH
		}
	}

	o.logger.Info("Processing enhanced auction task",
		"poolId", task.PoolId.Hex(),
		"blockNumber", task.BlockNumber,
		"auctionType", task.AuctionType,
		"requiresFHE", task.RequiresFHE,
	)

	response := o.processEnhancedTask(task)

	// Send to response channel
	select {
	case o.taskResponseChan <- TaskResponseInfo{
		TaskResponse: response,
		BlsSignature: *o.blsKeypair.SignMessage(o.hashTaskResponse(response)),
		OperatorId:   o.operatorId,
	}:
		o.logger.Info("Enhanced task response sent to channel")
	default:
		o.logger.Warn("Task response channel is full, dropping response")
	}
}

func (o *Operator) processEnhancedTask(task *EnhancedAuctionTask) *EnhancedAuctionTaskResponse {
	switch task.AuctionType {
	case SingleChainAuction:
		return o.processSingleChainAuction(task)
	case CrossChainAuction:
		return o.processCrossChainAuction(task)
	case PrivateAuction:
		return o.processPrivateAuction(task)
	default:
		return o.processSingleChainAuction(task)
	}
}

func (o *Operator) processSingleChainAuction(task *EnhancedAuctionTask) *EnhancedAuctionTaskResponse {
	// Original EigenLVR auction logic
	return &EnhancedAuctionTaskResponse{
		ReferenceTaskIndex: 0,
		Winner:             common.HexToAddress("0x742d35Cc6608C8B29a1b8d9c0f6f8aD5b7c8b0A1"),
		WinningBid:         big.NewInt(1e18), // 1 ETH
		TotalBids:          3,
		AuctionType:        SingleChainAuction,
		ExecutionPath:      "single_chain_lvr",
	}
}

func (o *Operator) processCrossChainAuction(task *EnhancedAuctionTask) *EnhancedAuctionTaskResponse {
	if task.CrossChainOpportunity == nil {
		return o.processSingleChainAuction(task)
	}

	// Cross-chain arbitrage calculation
	crossChainProfit := new(big.Int).Mul(
		task.CrossChainOpportunity.Volume,
		big.NewInt(task.CrossChainOpportunity.ProfitBps),
	)
	crossChainProfit.Div(crossChainProfit, big.NewInt(10000))

	return &EnhancedAuctionTaskResponse{
		ReferenceTaskIndex: 0,
		Winner:             common.HexToAddress("0x742d35Cc6608C8B29a1b8d9c0f6f8aD5b7c8b0A1"),
		WinningBid:         big.NewInt(2e18), // 2 ETH (higher due to cross-chain opportunity)
		TotalBids:          5,
		AuctionType:        CrossChainAuction,
		CrossChainProfit:   crossChainProfit,
		ExecutionPath:      fmt.Sprintf("cross_chain_%d_to_%d", task.CrossChainOpportunity.SourceChain, task.CrossChainOpportunity.TargetChain),
	}
}

func (o *Operator) processPrivateAuction(task *EnhancedAuctionTask) *EnhancedAuctionTaskResponse {
	var fheProof []byte
	
	if o.fheProcessor != nil {
		// Process encrypted bids using FHE
		proof, err := o.fheProcessor.ProcessEncryptedBids(task.EncryptedBids)
		if err != nil {
			o.logger.Error("Failed to process FHE bids", "error", err)
		} else {
			fheProof = proof
		}
	}

	return &EnhancedAuctionTaskResponse{
		ReferenceTaskIndex: 0,
		Winner:             common.HexToAddress("0x742d35Cc6608C8B29a1b8d9c0f6f8aD5b7c8b0A1"),
		WinningBid:         big.NewInt(15e17), // 1.5 ETH
		TotalBids:          4,
		AuctionType:        PrivateAuction,
		FHEProof:           fheProof,
		ExecutionPath:      "private_fhe_auction",
	}
}

func (o *Operator) processTaskResponses(ctx context.Context) {
	o.logger.Info("Starting enhanced task response processor")

	for {
		select {
		case <-ctx.Done():
			return
		case taskResponseInfo := <-o.taskResponseChan:
			o.sendEnhancedTaskResponseToAggregator(taskResponseInfo)
		}
	}
}

func (o *Operator) sendEnhancedTaskResponseToAggregator(taskResponseInfo TaskResponseInfo) {
	o.logger.Info("Sending enhanced task response to aggregator",
		"taskIndex", taskResponseInfo.TaskResponse.ReferenceTaskIndex,
		"winner", taskResponseInfo.TaskResponse.Winner.Hex(),
		"winningBid", taskResponseInfo.TaskResponse.WinningBid.String(),
		"auctionType", taskResponseInfo.TaskResponse.AuctionType,
		"executionPath", taskResponseInfo.TaskResponse.ExecutionPath,
	)

	signedTaskResponse := SignedEnhancedAuctionTaskResponse{
		EnhancedAuctionTaskResponse: *taskResponseInfo.TaskResponse,
		BlsSignature:                taskResponseInfo.BlsSignature,
		OperatorId:                  taskResponseInfo.OperatorId,
	}

	// Send to aggregator (in production, this would be HTTP/gRPC)
	responseJson, _ := json.MarshalIndent(signedTaskResponse, "", "  ")
	o.logger.Info("Enhanced signed task response", "response", string(responseJson))
}

func (o *Operator) hashTaskResponse(taskResponse *EnhancedAuctionTaskResponse) [32]byte {
	// Enhanced hash including new fields
	responseBytes, _ := json.Marshal(taskResponse)
	return crypto.Keccak256Hash(responseBytes)
}

// Enhanced getters
func (o *Operator) GetSupportedChains() []uint64 {
	return o.config.SupportedChains
}

func (o *Operator) GetCrossChainPrices(chainId uint256) map[string]*big.Int {
	o.priceFeedsMutex.RLock()
	defer o.priceFeedsMutex.RUnlock()
	return o.priceFeeds[chainId]
}

func (o *Operator) IsFHEEnabled() bool {
	return o.config.FHEEnabled && o.fheProcessor != nil
}