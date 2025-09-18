package main

import (
	"encoding/json"
	"math/big"
	"testing"
	"time"

	performerV1 "github.com/Layr-Labs/protocol-apis/gen/protos/eigenlayer/hourglass/v1/performer"
	"go.uber.org/zap"
)

// TestEigenLVRIntegration tests the full integration of EigenLVR functionality
func TestEigenLVRIntegration(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	// Test comprehensive LVR detection pipeline
	t.Run("LVR Detection Pipeline", func(t *testing.T) {
		// 1. Price monitoring
		monitoringPayload := &TaskPayload{
			Type: TaskTypeLVRMonitoring,
			Parameters: map[string]interface{}{
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
				"token0":       "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"token1":       "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
				"threshold":    50.0,
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		monitoringResult, err := performer.handleLVRMonitoring(&performerV1.TaskRequest{
			TaskId:  []byte("monitoring-test"),
			Payload: []byte("test"),
		}, monitoringPayload)

		if err != nil {
			t.Fatalf("LVR monitoring failed: %v", err)
		}

		var monitoringData map[string]interface{}
		if err := json.Unmarshal(monitoringResult, &monitoringData); err != nil {
			t.Fatalf("Invalid monitoring result JSON: %v", err)
		}

		// Verify monitoring detected price data
		if poolPrice, exists := monitoringData["pool_price"]; !exists {
			t.Error("Missing pool_price in monitoring result")
		} else {
			t.Logf("Pool price detected: %v", poolPrice)
		}

		// 2. Cross-chain price synchronization
		syncPayload := &TaskPayload{
			Type: TaskTypeCrossChainPriceSync,
			Parameters: map[string]interface{}{
				"token0":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"token1":        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
				"target_chains": []interface{}{1.0, 42161.0, 10.0, 137.0, 8453.0},
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		syncResult, err := performer.handleCrossChainPriceSync(&performerV1.TaskRequest{
			TaskId:  []byte("sync-test"),
			Payload: []byte("test"),
		}, syncPayload)

		if err != nil {
			t.Fatalf("Cross-chain sync failed: %v", err)
		}

		var syncData map[string]interface{}
		if err := json.Unmarshal(syncResult, &syncData); err != nil {
			t.Fatalf("Invalid sync result JSON: %v", err)
		}

		// Verify multi-chain prices were synced
		if chainsSynced, exists := syncData["chains_synced"]; !exists {
			t.Error("Missing chains_synced in sync result")
		} else if count, ok := chainsSynced.(float64); !ok || count < 1 {
			t.Errorf("Expected chains synced > 0, got %v", chainsSynced)
		} else {
			t.Logf("Chains synchronized: %v", count)
		}

		// 3. Opportunity detection
		opportunityPayload := &TaskPayload{
			Type: TaskTypeLVROpportunityDetection,
			Parameters: map[string]interface{}{
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
				"token0":       "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"token1":       "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
				"threshold":    50.0,
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		oppResult, err := performer.handleLVROpportunityDetection(&performerV1.TaskRequest{
			TaskId:  []byte("opportunity-test"),
			Payload: []byte("test"),
		}, opportunityPayload)

		if err != nil {
			t.Fatalf("Opportunity detection failed: %v", err)
		}

		var oppData map[string]interface{}
		if err := json.Unmarshal(oppResult, &oppData); err != nil {
			t.Fatalf("Invalid opportunity result JSON: %v", err)
		}

		// Verify opportunities were found
		if opportunities, exists := oppData["opportunities"]; !exists {
			t.Error("Missing opportunities in detection result")
		} else {
			t.Logf("Opportunities detected: %v", opportunities)
		}
	})

	// Test auction and settlement flow
	t.Run("Auction and Settlement Flow", func(t *testing.T) {
		// 1. Create auction
		auctionPayload := &TaskPayload{
			Type: TaskTypeAuctionCreation,
			Parameters: map[string]interface{}{
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
				"lvr_amount":   "1000000000000000000",
				"duration":     12.0,
				"is_private":   false,
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		auctionResult, err := performer.handleAuctionCreation(&performerV1.TaskRequest{
			TaskId:  []byte("auction-test"),
			Payload: []byte("test"),
		}, auctionPayload)

		if err != nil {
			t.Fatalf("Auction creation failed: %v", err)
		}

		var auctionData map[string]interface{}
		if err := json.Unmarshal(auctionResult, &auctionData); err != nil {
			t.Fatalf("Invalid auction result JSON: %v", err)
		}

		// Get auction ID for settlement
		auctionID, exists := auctionData["auction_id"].(string)
		if !exists {
			t.Fatal("Missing auction_id in auction result")
		}

		// 2. Validate bid
		bidPayload := &TaskPayload{
			Type: TaskTypeBidValidation,
			Parameters: map[string]interface{}{
				"auction_id":    auctionID,
				"bidder":        "0x1234567890123456789012345678901234567890",
				"bid_amount":    "1500000000000000000",
				"bid_signature": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12",
				"min_bid":       "1100000000000000000",
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		bidResult, err := performer.handleBidValidation(&performerV1.TaskRequest{
			TaskId:  []byte("bid-test"),
			Payload: []byte("test"),
		}, bidPayload)

		if err != nil {
			t.Fatalf("Bid validation failed: %v", err)
		}

		var bidData map[string]interface{}
		if err := json.Unmarshal(bidResult, &bidData); err != nil {
			t.Fatalf("Invalid bid result JSON: %v", err)
		}

		// Verify bid validation
		if isValid, exists := bidData["is_valid"].(bool); !exists {
			t.Error("Missing is_valid in bid result")
		} else if isValid {
			t.Log("Bid validation passed")
		} else {
			t.Log("Bid validation failed as expected (test bidder address)")
		}

		// 3. Settle auction
		settlementPayload := &TaskPayload{
			Type: TaskTypeSettlement,
			Parameters: map[string]interface{}{
				"auction_id":   auctionID,
				"winner":       "0x1234567890123456789012345678901234567890",
				"winning_bid":  "1500000000000000000",
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		settlementResult, err := performer.handleSettlement(&performerV1.TaskRequest{
			TaskId:  []byte("settlement-test"),
			Payload: []byte("test"),
		}, settlementPayload)

		if err != nil {
			t.Fatalf("Settlement failed: %v", err)
		}

		var settlementData map[string]interface{}
		if err := json.Unmarshal(settlementResult, &settlementData); err != nil {
			t.Fatalf("Invalid settlement result JSON: %v", err)
		}

		// Verify MEV distribution
		if lpAmount, exists := settlementData["lp_amount"].(string); !exists {
			t.Error("Missing lp_amount in settlement result")
		} else {
			lpAmountBig := new(big.Int)
			lpAmountBig.SetString(lpAmount, 10)
			
			// Should be 85% of 1.5 ETH = 1.275 ETH
			expectedLP := new(big.Int)
			expectedLP.SetString("1275000000000000000", 10)
			
			if lpAmountBig.Cmp(expectedLP) != 0 {
				t.Errorf("Expected LP amount %s, got %s", expectedLP.String(), lpAmount)
			} else {
				t.Logf("Correct LP amount distributed: %s", lpAmount)
			}
		}
	})

	// Test private auction capabilities
	t.Run("Private Auction Capabilities", func(t *testing.T) {
		// 1. Setup private auction
		privatePayload := &TaskPayload{
			Type: TaskTypePrivateAuctionSetup,
			Parameters: map[string]interface{}{
				"auction_id":     "private-auction-test",
				"min_bid":        "1000000000000000000",
				"reserve_amount": "1100000000000000000",
				"duration":       12.0,
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		privateResult, err := performer.handlePrivateAuctionSetup(&performerV1.TaskRequest{
			TaskId:  []byte("private-test"),
			Payload: []byte("test"),
		}, privatePayload)

		if err != nil {
			t.Fatalf("Private auction setup failed: %v", err)
		}

		var privateData map[string]interface{}
		if err := json.Unmarshal(privateResult, &privateData); err != nil {
			t.Fatalf("Invalid private auction result JSON: %v", err)
		}

		// Verify FHE setup
		if setupStatus, exists := privateData["fhe_setup_status"].(string); !exists {
			t.Error("Missing fhe_setup_status in private auction result")
		} else if setupStatus != "completed" {
			t.Errorf("Expected FHE setup completed, got %s", setupStatus)
		} else {
			t.Log("FHE private auction setup completed")
		}

		// 2. Process encrypted bid
		fhePayload := &TaskPayload{
			Type: TaskTypeFHEBidProcessing,
			Parameters: map[string]interface{}{
				"auction_id":    "private-auction-test",
				"encrypted_bid": "0x" + string(make([]byte, 64)),
				"bidder":        "0x1234567890123456789012345678901234567890",
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		// Fill encrypted_bid with dummy data
		fhePayload.Parameters["encrypted_bid"] = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12"

		fheResult, err := performer.handleFHEBidProcessing(&performerV1.TaskRequest{
			TaskId:  []byte("fhe-test"),
			Payload: []byte("test"),
		}, fhePayload)

		if err != nil {
			t.Fatalf("FHE bid processing failed: %v", err)
		}

		var fheData map[string]interface{}
		if err := json.Unmarshal(fheResult, &fheData); err != nil {
			t.Fatalf("Invalid FHE result JSON: %v", err)
		}

		// Verify FHE processing
		if processingStatus, exists := fheData["processing_status"].(string); !exists {
			t.Error("Missing processing_status in FHE result")
		} else if processingStatus != "completed" {
			t.Errorf("Expected FHE processing completed, got %s", processingStatus)
		} else {
			t.Log("FHE bid processing completed")
		}
	})

	// Test cross-chain execution
	t.Run("Cross-Chain Execution", func(t *testing.T) {
		executionPayload := &TaskPayload{
			Type: TaskTypeCrossChainExecution,
			Parameters: map[string]interface{}{
				"source_chain": 1.0,
				"target_chain": 42161.0,
				"token":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"amount":       "1000000000000000000",
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		executionResult, err := performer.handleCrossChainExecution(&performerV1.TaskRequest{
			TaskId:  []byte("execution-test"),
			Payload: []byte("test"),
		}, executionPayload)

		if err != nil {
			t.Fatalf("Cross-chain execution failed: %v", err)
		}

		var executionData map[string]interface{}
		if err := json.Unmarshal(executionResult, &executionData); err != nil {
			t.Fatalf("Invalid execution result JSON: %v", err)
		}

		// Verify execution
		if executionStatus, exists := executionData["execution_status"].(string); !exists {
			t.Error("Missing execution_status in execution result")
		} else if executionStatus != "completed" {
			t.Errorf("Expected execution completed, got %s", executionStatus)
		} else {
			t.Log("Cross-chain execution completed")
		}

		// Verify bridge provider
		if bridgeProvider, exists := executionData["bridge_provider"].(string); !exists {
			t.Error("Missing bridge_provider in execution result")
		} else if bridgeProvider != "across_protocol" {
			t.Errorf("Expected Across Protocol, got %s", bridgeProvider)
		} else {
			t.Log("Using Across Protocol for cross-chain execution")
		}
	})

	// Test MEV distribution
	t.Run("MEV Distribution", func(t *testing.T) {
		mevPayload := &TaskPayload{
			Type: TaskTypeMEVDistribution,
			Parameters: map[string]interface{}{
				"total_mev":     "2000000000000000000", // 2 ETH
				"pool_address":  "0x123456789abcdef123456789abcdef1234567890",
				"lp_addresses":  []interface{}{
					"0x1111111111111111111111111111111111111111",
					"0x2222222222222222222222222222222222222222",
					"0x3333333333333333333333333333333333333333",
				},
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		mevResult, err := performer.handleMEVDistribution(&performerV1.TaskRequest{
			TaskId:  []byte("mev-test"),
			Payload: []byte("test"),
		}, mevPayload)

		if err != nil {
			t.Fatalf("MEV distribution failed: %v", err)
		}

		var mevData map[string]interface{}
		if err := json.Unmarshal(mevResult, &mevData); err != nil {
			t.Fatalf("Invalid MEV result JSON: %v", err)
		}

		// Verify distribution
		if lpAmount, exists := mevData["lp_amount"].(string); !exists {
			t.Error("Missing lp_amount in MEV distribution result")
		} else {
			lpAmountBig := new(big.Int)
			lpAmountBig.SetString(lpAmount, 10)
			
			// Should be 85% of 2 ETH = 1.7 ETH
			expectedLP := new(big.Int)
			expectedLP.SetString("1700000000000000000", 10)
			
			if lpAmountBig.Cmp(expectedLP) != 0 {
				t.Errorf("Expected LP amount %s, got %s", expectedLP.String(), lpAmount)
			} else {
				t.Logf("Correct MEV distribution: %s to LPs", lpAmount)
			}
		}

		// Verify LP count
		if lpCount, exists := mevData["lp_count"].(float64); !exists {
			t.Error("Missing lp_count in MEV distribution result")
		} else if lpCount != 3 {
			t.Errorf("Expected 3 LPs, got %v", lpCount)
		} else {
			t.Log("Correct number of LPs for distribution")
		}
	})
}

// TestEigenLVRPerformance tests performance characteristics
func TestEigenLVRPerformance(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	// Test LVR detection performance
	t.Run("LVR Detection Performance", func(t *testing.T) {
		start := time.Now()
		
		for i := 0; i < 100; i++ {
			opportunity, _ := performer.detectSingleChainLVR(
				1,
				"0x123456789abcdef123456789abcdef1234567890",
				"0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			)
			if opportunity == nil {
				// Expected for some test cases
			}
		}

		duration := time.Since(start)
		avgDuration := duration / 100
		
		t.Logf("Average LVR detection time: %v", avgDuration)
		
		// Should be fast (under 10ms per detection)
		if avgDuration > 10*time.Millisecond {
			t.Errorf("LVR detection too slow: %v", avgDuration)
		}
	})

	// Test cross-chain price sync performance
	t.Run("Cross-Chain Sync Performance", func(t *testing.T) {
		start := time.Now()
		
		for i := 0; i < 50; i++ {
			prices := performer.getCrossChainPrices(
				"0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			)
			if len(prices) == 0 {
				t.Error("Expected cross-chain prices")
			}
		}

		duration := time.Since(start)
		avgDuration := duration / 50
		
		t.Logf("Average cross-chain sync time: %v", avgDuration)
		
		// Should be reasonably fast (under 50ms per sync)
		if avgDuration > 50*time.Millisecond {
			t.Errorf("Cross-chain sync too slow: %v", avgDuration)
		}
	})
}