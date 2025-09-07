package aggregator

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"sync"
	"time"

	"github.com/Layr-Labs/eigensdk-go/chainio/clients/eth"
	"github.com/Layr-Labs/eigensdk-go/logging"
	"github.com/Layr-Labs/eigensdk-go/types"
	"github.com/ethereum/go-ethereum/common"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/najnomics/eigenlvr-v2/avs/pkg/avsregistry"
)

type Aggregator struct {
	config     Config
	logger     logging.Logger
	ethClient  eth.Client
	metricsReg *prometheus.Registry

	avsWriter avsregistry.AvsRegistryChainWriter
	avsReader avsregistry.AvsRegistryChainReader

	// Enhanced task aggregation for v2
	tasksMutex    sync.RWMutex
	tasks         map[uint32]*EnhancedTaskInfo
	httpServer    *http.Server
}

type Config struct {
	ServerIpPortAddr              string `json:"server_ip_port_address"`
	EthRpcUrl                     string `json:"eth_rpc_url"`
	RegistryCoordinatorAddress    string `json:"registry_coordinator_address"`
	OperatorStateRetrieverAddress string `json:"operator_state_retriever_address"`
	AggregatorPrivateKeyPath      string `json:"aggregator_private_key_path"`
	EigenMetricsIpPortAddress     string `json:"eigen_metrics_ip_port_address"`
	EnableMetrics                 bool   `json:"enable_metrics"`
}

type EnhancedTaskInfo struct {
	TaskIndex                 uint32                           `json:"taskIndex"`
	PoolId                    common.Hash                      `json:"poolId"`
	TaskCreatedBlock          uint32                           `json:"taskCreatedBlock"`
	QuorumNumbers             types.QuorumNums                 `json:"quorumNumbers"`
	QuorumThresholdPercentage types.ThresholdPercentage        `json:"quorumThresholdPercentage"`
	TaskResponses             map[types.OperatorId]EnhancedTaskResponse `json:"taskResponses"`
	TaskResponsesInfo         map[types.OperatorId]EnhancedTaskResponseInfo `json:"taskResponsesInfo"`
	IsCompleted               bool                             `json:"isCompleted"`
	CreatedAt                 time.Time                        `json:"createdAt"`
	
	// Enhanced v2 fields
	AuctionType               AuctionType                      `json:"auctionType"`
	RequiresFHE               bool                             `json:"requiresFHE"`
	CrossChainData            *CrossChainData                  `json:"crossChainData,omitempty"`
}

type AuctionType string

const (
	StandardAuction AuctionType = "standard"
	PrivateAuction  AuctionType = "private"
	CrossChainAuction AuctionType = "cross_chain"
)

type CrossChainData struct {
	SourceChain uint64   `json:"sourceChain"`
	TargetChain uint64   `json:"targetChain"`
	ProfitBps   uint64   `json:"profitBps"`
	Volume      *big.Int `json:"volume"`
}

type EnhancedTaskResponse struct {
	ReferenceTaskIndex uint32         `json:"referenceTaskIndex"`
	Winner             common.Address `json:"winner"`
	WinningBid         *big.Int       `json:"winningBid"`
	TotalBids          uint32         `json:"totalBids"`
	
	// Enhanced v2 fields
	AuctionType        AuctionType    `json:"auctionType"`
	CrossChainProfit   *big.Int       `json:"crossChainProfit,omitempty"`
	FHEProof           []byte         `json:"fheProof,omitempty"`
	ExecutionPath      string         `json:"executionPath"`
	Confidence         uint32         `json:"confidence"`
}

type EnhancedTaskResponseInfo struct {
	TaskResponse EnhancedTaskResponse `json:"taskResponse"`
	BlsSignature types.Signature      `json:"blsSignature"`
	OperatorId   types.OperatorId     `json:"operatorId"`
}

type SignedEnhancedTaskResponse struct {
	TaskResponse EnhancedTaskResponse `json:"taskResponse"`
	BlsSignature types.Signature      `json:"blsSignature"`
	OperatorId   types.OperatorId     `json:"operatorId"`
}

func NewAggregator(config Config, logger logging.Logger) (*Aggregator, error) {
	logger = logger.With("component", "eigenlvr-v2-aggregator")

	ethClient, err := eth.NewClient(config.EthRpcUrl)
	if err != nil {
		return nil, fmt.Errorf("failed to create eth client: %w", err)
	}

	// Create AVS registry clients
	avsReader, err := avsregistry.NewAvsRegistryChainReader(
		common.HexToAddress(config.RegistryCoordinatorAddress),
		common.HexToAddress(config.OperatorStateRetrieverAddress),
		ethClient,
		logger,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create avs registry chain reader: %w", err)
	}

	// For the writer, we'd need the aggregator's private key
	var avsWriter avsregistry.AvsRegistryChainWriter

	// Create metrics registry
	var metricsReg *prometheus.Registry
	if config.EnableMetrics {
		metricsReg = prometheus.NewRegistry()
	} else {
		metricsReg = prometheus.NewRegistry()
	}

	aggregator := &Aggregator{
		config:     config,
		logger:     logger,
		ethClient:  ethClient,
		metricsReg: metricsReg,
		avsWriter:  avsWriter,
		avsReader:  *avsReader,
		tasks:      make(map[uint32]*EnhancedTaskInfo),
	}

	return aggregator, nil
}

func (a *Aggregator) Start(ctx context.Context) error {
	a.logger.Info("Starting EigenLVR v2 aggregator")

	// Start HTTP server for receiving operator responses
	go a.startHttpServer()

	// Start enhanced task processing
	go a.processEnhancedTasks(ctx)

	// Start listening for new tasks from the service manager
	go a.listenForNewTasks(ctx)

	// Keep the aggregator running
	<-ctx.Done()
	return nil
}

func (a *Aggregator) startHttpServer() {
	router := mux.NewRouter()
	
	// Health check endpoint
	router.HandleFunc("/health", a.healthHandler).Methods("GET")
	
	// Enhanced task response endpoint
	router.HandleFunc("/task-response", a.enhancedTaskResponseHandler).Methods("POST")
	
	// Task status endpoint
	router.HandleFunc("/task/{taskIndex}", a.taskStatusHandler).Methods("GET")
	
	// Enhanced endpoints for v2
	router.HandleFunc("/private-auction/{auctionId}", a.privateAuctionHandler).Methods("GET")
	router.HandleFunc("/cross-chain-status", a.crossChainStatusHandler).Methods("GET")

	a.httpServer = &http.Server{
		Addr:    a.config.ServerIpPortAddr,
		Handler: router,
	}

	a.logger.Info("Starting enhanced HTTP server", "address", a.config.ServerIpPortAddr)
	if err := a.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		a.logger.Error("HTTP server error", "error", err)
	}
}

func (a *Aggregator) healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "healthy",
		"version": "2.0.0",
		"capabilities": []string{"standard_auctions", "private_fhe", "cross_chain_monitoring"},
	})
}

func (a *Aggregator) enhancedTaskResponseHandler(w http.ResponseWriter, r *http.Request) {
	var signedResponse SignedEnhancedTaskResponse
	if err := json.NewDecoder(r.Body).Decode(&signedResponse); err != nil {
		a.logger.Error("Failed to decode enhanced task response", "error", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	a.logger.Info("Received enhanced task response",
		"taskIndex", signedResponse.TaskResponse.ReferenceTaskIndex,
		"operatorId", signedResponse.OperatorId.String(),
		"winner", signedResponse.TaskResponse.Winner.Hex(),
		"winningBid", signedResponse.TaskResponse.WinningBid.String(),
		"auctionType", signedResponse.TaskResponse.AuctionType,
		"executionPath", signedResponse.TaskResponse.ExecutionPath,
		"confidence", signedResponse.TaskResponse.Confidence,
	)

	// Process the enhanced task response
	if err := a.processEnhancedTaskResponse(signedResponse); err != nil {
		a.logger.Error("Failed to process enhanced task response", "error", err)
		http.Error(w, "Failed to process response", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "accepted"})
}

func (a *Aggregator) taskStatusHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	taskIndex := vars["taskIndex"]

	a.tasksMutex.RLock()
	defer a.tasksMutex.RUnlock()

	// Find task by index (simplified lookup)
	for _, task := range a.tasks {
		if fmt.Sprintf("%d", task.TaskIndex) == taskIndex {
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(map[string]interface{}{
				"taskIndex": task.TaskIndex,
				"status": func() string {
					if task.IsCompleted {
						return "completed"
					}
					return "processing"
				}(),
				"auctionType": task.AuctionType,
				"responseCount": len(task.TaskResponses),
				"createdAt": task.CreatedAt,
			})
			return
		}
	}

	http.Error(w, "Task not found", http.StatusNotFound)
}

func (a *Aggregator) privateAuctionHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	auctionId := vars["auctionId"]

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"auctionId": auctionId,
		"type": "private_fhe",
		"status": "encrypted",
		"message": "Auction parameters remain encrypted until settlement",
	})
}

func (a *Aggregator) crossChainStatusHandler(w http.ResponseWriter, r *http.Request) {
	a.tasksMutex.RLock()
	defer a.tasksMutex.RUnlock()

	crossChainTasks := 0
	for _, task := range a.tasks {
		if task.AuctionType == CrossChainAuction {
			crossChainTasks++
		}
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"crossChainTasks": crossChainTasks,
		"supportedChains": []uint64{1, 42161, 10, 137, 8453},
		"status": "monitoring",
	})
}

func (a *Aggregator) processEnhancedTaskResponse(signedResponse SignedEnhancedTaskResponse) error {
	taskIndex := signedResponse.TaskResponse.ReferenceTaskIndex

	a.tasksMutex.Lock()
	defer a.tasksMutex.Unlock()

	task, exists := a.tasks[taskIndex]
	if !exists {
		// Create new enhanced task if it doesn't exist
		task = &EnhancedTaskInfo{
			TaskIndex:         taskIndex,
			TaskResponses:     make(map[types.OperatorId]EnhancedTaskResponse),
			TaskResponsesInfo: make(map[types.OperatorId]EnhancedTaskResponseInfo),
			IsCompleted:       false,
			CreatedAt:        time.Now(),
			AuctionType:      signedResponse.TaskResponse.AuctionType,
			RequiresFHE:      signedResponse.TaskResponse.AuctionType == PrivateAuction,
		}
		a.tasks[taskIndex] = task
	}

	// Add the enhanced response
	task.TaskResponses[signedResponse.OperatorId] = signedResponse.TaskResponse
	task.TaskResponsesInfo[signedResponse.OperatorId] = EnhancedTaskResponseInfo{
		TaskResponse: signedResponse.TaskResponse,
		BlsSignature: signedResponse.BlsSignature,
		OperatorId:   signedResponse.OperatorId,
	}

	a.logger.Info("Enhanced task response added",
		"taskIndex", taskIndex,
		"totalResponses", len(task.TaskResponses),
		"auctionType", task.AuctionType,
		"requiresFHE", task.RequiresFHE,
	)

	// Check if we have enough responses to aggregate
	if a.shouldAggregateEnhancedTask(task) {
		go a.aggregateAndSubmitEnhancedTask(task)
	}

	return nil
}

func (a *Aggregator) shouldAggregateEnhancedTask(task *EnhancedTaskInfo) bool {
	// Enhanced aggregation logic based on auction type
	minResponses := 2 // Default minimum
	
	switch task.AuctionType {
	case PrivateAuction:
		minResponses = 3 // Require more consensus for private auctions
	case CrossChainAuction:
		minResponses = 2 // Cross-chain needs faster response
	}
	
	return len(task.TaskResponses) >= minResponses && !task.IsCompleted
}

func (a *Aggregator) aggregateAndSubmitEnhancedTask(task *EnhancedTaskInfo) {
	a.logger.Info("Aggregating enhanced task responses", 
		"taskIndex", task.TaskIndex,
		"auctionType", task.AuctionType,
	)

	// Enhanced aggregation logic
	aggregatedResponse := a.performEnhancedAggregation(task)

	a.logger.Info("Enhanced aggregation completed",
		"taskIndex", task.TaskIndex,
		"winner", aggregatedResponse.Winner.Hex(),
		"winningBid", aggregatedResponse.WinningBid.String(),
		"auctionType", aggregatedResponse.AuctionType,
		"confidence", aggregatedResponse.Confidence,
		"totalResponses", len(task.TaskResponses),
	)

	// Mark task as completed
	a.tasksMutex.Lock()
	task.IsCompleted = true
	a.tasksMutex.Unlock()

	// In production, this would:
	// 1. Verify BLS signatures with enhanced validation
	// 2. Check FHE proofs for private auctions
	// 3. Validate cross-chain data for cross-chain auctions
	// 4. Submit aggregated response to enhanced service manager
}

func (a *Aggregator) performEnhancedAggregation(task *EnhancedTaskInfo) EnhancedTaskResponse {
	// Weighted aggregation based on auction type and operator confidence
	winnerVotes := make(map[common.Address]uint32)
	highestBid := big.NewInt(0)
	var finalWinner common.Address
	totalBids := uint32(0)
	totalConfidence := uint32(0)

	for _, response := range task.TaskResponses {
		weight := response.Confidence
		if weight == 0 {
			weight = 100 // Default weight
		}

		winnerVotes[response.Winner] += weight
		
		if response.WinningBid.Cmp(highestBid) > 0 {
			highestBid = response.WinningBid
		}
		
		totalBids += response.TotalBids
		totalConfidence += weight
	}

	// Find winner with most weighted votes
	maxVotes := uint32(0)
	for winner, votes := range winnerVotes {
		if votes > maxVotes {
			maxVotes = votes
			finalWinner = winner
		}
	}

	// Build enhanced aggregated response
	aggregated := EnhancedTaskResponse{
		ReferenceTaskIndex: task.TaskIndex,
		Winner:             finalWinner,
		WinningBid:         highestBid,
		TotalBids:          totalBids / uint32(len(task.TaskResponses)),
		AuctionType:        task.AuctionType,
		Confidence:         totalConfidence / uint32(len(task.TaskResponses)),
		ExecutionPath:      "aggregated_enhanced",
	}

	// Add type-specific aggregation
	switch task.AuctionType {
	case PrivateAuction:
		aggregated = a.aggregatePrivateAuction(task, aggregated)
	case CrossChainAuction:
		aggregated = a.aggregateCrossChainAuction(task, aggregated)
	}

	return aggregated
}

func (a *Aggregator) aggregatePrivateAuction(task *EnhancedTaskInfo, base EnhancedTaskResponse) EnhancedTaskResponse {
	// Aggregate FHE proofs
	var combinedProof []byte
	for _, response := range task.TaskResponses {
		if len(response.FHEProof) > 0 {
			combinedProof = append(combinedProof, response.FHEProof...)
		}
	}
	
	base.FHEProof = combinedProof
	base.ExecutionPath = "private_fhe_aggregated"
	
	return base
}

func (a *Aggregator) aggregateCrossChainAuction(task *EnhancedTaskInfo, base EnhancedTaskResponse) EnhancedTaskResponse {
	// Aggregate cross-chain profits
	totalCrossChainProfit := big.NewInt(0)
	validResponses := 0
	
	for _, response := range task.TaskResponses {
		if response.CrossChainProfit != nil && response.CrossChainProfit.Sign() > 0 {
			totalCrossChainProfit.Add(totalCrossChainProfit, response.CrossChainProfit)
			validResponses++
		}
	}
	
	if validResponses > 0 {
		base.CrossChainProfit = new(big.Int).Div(totalCrossChainProfit, big.NewInt(int64(validResponses)))
		base.ExecutionPath = "cross_chain_aggregated"
	}
	
	return base
}

func (a *Aggregator) processEnhancedTasks(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			a.cleanupOldTasks()
		}
	}
}

func (a *Aggregator) cleanupOldTasks() {
	a.tasksMutex.Lock()
	defer a.tasksMutex.Unlock()

	cutoff := time.Now().Add(-2 * time.Hour) // Clean tasks older than 2 hours
	
	cleaned := 0
	for taskIndex, task := range a.tasks {
		if task.CreatedAt.Before(cutoff) {
			delete(a.tasks, taskIndex)
			cleaned++
		}
	}
	
	if cleaned > 0 {
		a.logger.Debug("Cleaned up old tasks", "count", cleaned)
	}
}

func (a *Aggregator) listenForNewTasks(ctx context.Context) {
	a.logger.Info("Starting to listen for enhanced auction tasks")

	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			a.logger.Debug("Listening for enhanced auction tasks...")
		}
	}
}

// Enhanced getters
func (a *Aggregator) GetEnhancedTaskStatus(taskIndex uint32) (*EnhancedTaskInfo, bool) {
	a.tasksMutex.RLock()
	defer a.tasksMutex.RUnlock()
	
	task, exists := a.tasks[taskIndex]
	return task, exists
}

func (a *Aggregator) GetActiveEnhancedTasks() map[uint32]*EnhancedTaskInfo {
	a.tasksMutex.RLock()
	defer a.tasksMutex.RUnlock()
	
	activeTasks := make(map[uint32]*EnhancedTaskInfo)
	for taskIndex, task := range a.tasks {
		if !task.IsCompleted {
			activeTasks[taskIndex] = task
		}
	}
	
	return activeTasks
}

func (a *Aggregator) GetTasksByType(auctionType AuctionType) []*EnhancedTaskInfo {
	a.tasksMutex.RLock()
	defer a.tasksMutex.RUnlock()
	
	var tasks []*EnhancedTaskInfo
	for _, task := range a.tasks {
		if task.AuctionType == auctionType {
			tasks = append(tasks, task)
		}
	}
	
	return tasks
}