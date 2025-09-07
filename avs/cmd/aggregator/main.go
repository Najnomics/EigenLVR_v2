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

	"github.com/Layr-Labs/eigensdk-go/logging"
	"github.com/spf13/cobra"

	"github.com/najnomics/eigenlvr-v2/avs/aggregator"
)

var (
	configFile string
	logLevel   string
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "eigenlvr-v2-aggregator",
		Short: "EigenLVR v2 Aggregator - Enhanced MEV protection aggregator service",
		Long: `EigenLVR v2 Aggregator collects and aggregates responses from operators:
		
- Aggregates standard and private auction results
- Validates FHE proofs for private auctions
- Handles cross-chain arbitrage coordination
- Provides REST API for monitoring and management
- Integrates with EigenLayer AVS infrastructure

The aggregator is responsible for collecting operator responses,
performing consensus, and submitting final results to the blockchain.`,
		Run: runAggregator,
	}

	rootCmd.Flags().StringVarP(&configFile, "config", "c", "config/aggregator.yaml", "Path to configuration file")
	rootCmd.Flags().StringVarP(&logLevel, "log-level", "l", "info", "Log level (debug, info, warn, error)")

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func runAggregator(cmd *cobra.Command, args []string) {
	// Setup logging
	logger, err := logging.NewZapLogger(logging.Development)
	if err != nil {
		log.Fatalf("Failed to create logger: %v", err)
	}
	
	logger.Info("Starting EigenLVR v2 Aggregator",
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
		"serverAddr", config.ServerIpPortAddr,
		"ethRpcUrl", config.EthRpcUrl,
		"metricsEnabled", config.EnableMetrics,
	)

	// Create aggregator instance
	agg, err := aggregator.NewAggregator(*config, logger)
	if err != nil {
		logger.Fatal("Failed to create aggregator", "error", err)
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

	// Start aggregator
	logger.Info("Starting EigenLVR v2 aggregator services...")
	
	if err := agg.Start(ctx); err != nil {
		logger.Fatal("Aggregator failed", "error", err)
	}

	logger.Info("EigenLVR v2 aggregator shutdown complete")
}

func loadConfig(configFile string) (*aggregator.Config, error) {
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

	var config aggregator.Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %w", err)
	}

	return &config, nil
}

func createDefaultConfig(configFile string) (*aggregator.Config, error) {
	config := &aggregator.Config{
		ServerIpPortAddr:              "0.0.0.0:8090",
		EthRpcUrl:                     "http://localhost:8545",
		RegistryCoordinatorAddress:    "0x0000000000000000000000000000000000000000",
		OperatorStateRetrieverAddress: "0x0000000000000000000000000000000000000000",
		AggregatorPrivateKeyPath:      "keys/aggregator_private_key",
		EigenMetricsIpPortAddress:     "localhost:9092",
		EnableMetrics:                 true,
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
	fmt.Println("Please review and update the configuration before running the aggregator.")
	
	return config, nil
}

func validateConfig(config *aggregator.Config) error {
	if config.EthRpcUrl == "" {
		return fmt.Errorf("eth_rpc_url is required")
	}

	if config.ServerIpPortAddr == "" {
		return fmt.Errorf("server_ip_port_address is required")
	}

	if config.RegistryCoordinatorAddress == "" {
		return fmt.Errorf("registry_coordinator_address is required")
	}

	if config.OperatorStateRetrieverAddress == "" {
		return fmt.Errorf("operator_state_retriever_address is required")
	}

	return nil
}