package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/Layr-Labs/eigensdk-go/logging"
	"github.com/spf13/cobra"

	"github.com/najnomics/eigenlvr-v2/avs/operator"
)

var (
	configFile string
	logLevel   string
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "eigenlvr-v2-operator",
		Short: "EigenLVR v2 Operator - Enhanced MEV protection with FHE and cross-chain capabilities",
		Long: `EigenLVR v2 Operator provides enhanced MEV protection through:
		
- Fully Homomorphic Encryption (FHE) for private auctions
- Cross-chain price monitoring for better LVR detection  
- Backwards compatible with original EigenLVR infrastructure
- Production-ready with comprehensive monitoring

This operator validates auction results and provides cryptographic proofs
for the enhanced EigenLVR system.`,
		Run: runOperator,
	}

	rootCmd.Flags().StringVarP(&configFile, "config", "c", "config/operator.yaml", "Path to configuration file")
	rootCmd.Flags().StringVarP(&logLevel, "log-level", "l", "info", "Log level (debug, info, warn, error)")

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func runOperator(cmd *cobra.Command, args []string) {
	// Setup logging
	logger, err := logging.NewZapLogger(logging.Development)
	if err != nil {
		log.Fatalf("Failed to create logger: %v", err)
	}
	
	logger.Info("Starting EigenLVR v2 Operator",
		"version", "2.0.0",
		"configFile", configFile,
		"logLevel", logLevel,
	)

	// Load configuration
	config, err := loadConfig(configFile)
	if err != nil {
		logger.Fatal("Failed to load configuration", "error", err)
	}

	// Validate configuration
	if err := validateConfig(config); err != nil {
		logger.Fatal("Invalid configuration", "error", err)
	}

	logger.Info("Configuration loaded successfully",
		"ethRpcUrl", config.EthRpcUrl,
		"supportedChains", config.SupportedChains,
		"fheEnabled", config.FHEEnabled,
		"crossChainEnabled", len(config.CrossChainRpcUrls) > 0,
	)

	// Create operator instance
	op, err := operator.NewOperator(*config, logger)
	if err != nil {
		logger.Fatal("Failed to create operator", "error", err)
	}

	// Setup graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle shutdown signals
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigChan
		logger.Info("Received shutdown signal", "signal", sig)
		cancel()
	}()

	// Start operator
	logger.Info("Starting EigenLVR v2 operator services...")
	
	if err := op.Start(ctx); err != nil {
		logger.Fatal("Operator failed", "error", err)
	}

	logger.Info("EigenLVR v2 operator shutdown complete")
}

func loadConfig(configFile string) (*operator.Config, error) {
	// Check if config file exists
	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		// Create default config
		return createDefaultConfig(configFile)
	}

	// Load existing config
	data, err := ioutil.ReadFile(configFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	var config operator.Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %w", err)
	}

	return &config, nil
}

func createDefaultConfig(configFile string) (*operator.Config, error) {
	config := &operator.Config{
		EcdsaPrivateKeyStorePath:      "keys/ecdsa_private_key",
		BlsPrivateKeyStorePath:        "keys/bls_private_key",
		EthRpcUrl:                     "http://localhost:8545",
		EthWsUrl:                      "ws://localhost:8545",
		RegistryCoordinatorAddress:    "0x0000000000000000000000000000000000000000",
		OperatorStateRetrieverAddress: "0x0000000000000000000000000000000000000000",
		AggregatorServerIpPortAddr:    "localhost:8090",
		RegisterOperatorOnStartup:     true,
		EigenMetricsIpPortAddress:     "localhost:9090",
		EnableMetrics:                 true,
		NodeApiIpPortAddress:          "localhost:9091",
		EnableNodeApi:                 true,
		
		// Enhanced v2 configuration
		SupportedChains:              []uint64{1, 42161, 10, 137, 8453},
		CrossChainRpcUrls: map[string]string{
			"1":     "http://localhost:8545",
			"42161": "https://arb1.arbitrum.io/rpc",
			"10":    "https://mainnet.optimism.io",
			"137":   "https://polygon-rpc.com",
			"8453":  "https://mainnet.base.org",
		},
		FHEEnabled:               true,
		FHEPrivateKeyPath:        "keys/fhe_private_key",
		CrossChainUpdateInterval: 30 * time.Second,
	}

	// Write default config to file
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("failed to marshal default config: %w", err)
	}

	// Create directory if it doesn't exist
	if err := os.MkdirAll(filepath.Dir(configFile), 0755); err != nil {
		return nil, fmt.Errorf("failed to create config directory: %w", err)
	}

	if err := ioutil.WriteFile(configFile, data, 0644); err != nil {
		return nil, fmt.Errorf("failed to write default config: %w", err)
	}

	fmt.Printf("Created default configuration file: %s\n", configFile)
	fmt.Println("Please review and update the configuration before running the operator.")
	
	return config, nil
}

func validateConfig(config *operator.Config) error {
	if config.EthRpcUrl == "" {
		return fmt.Errorf("eth_rpc_url is required")
	}

	if config.EcdsaPrivateKeyStorePath == "" {
		return fmt.Errorf("ecdsa_private_key_store_path is required")
	}

	if config.BlsPrivateKeyStorePath == "" {
		return fmt.Errorf("bls_private_key_store_path is required")
	}

	if len(config.SupportedChains) == 0 {
		return fmt.Errorf("at least one supported chain is required")
	}

	if config.FHEEnabled && config.FHEPrivateKeyPath == "" {
		return fmt.Errorf("fhe_private_key_path is required when FHE is enabled")
	}

	return nil
}