package main

import (
	"encoding/json"
	"fmt"
	"math/big"
	"testing"
	"time"

	performerV1 "github.com/Layr-Labs/protocol-apis/gen/protos/eigenlayer/hourglass/v1/performer"
	"go.uber.org/zap"
)

func Test_EigenLVRTaskRequestPayload(t *testing.T) {
	// ------------------------------------------------------------------------
	// EigenLVR Task Tests
	// ------------------------------------------------------------------------

	logger, err := zap.NewDevelopment()
	if err != nil {
		t.Errorf("Failed to create logger: %v", err)
	}

	performer := NewEigenLVRPerformer(logger)

	// Test basic task validation with valid JSON payload
	payload := TaskPayload{
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

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		t.Errorf("Failed to marshal payload: %v", err)
		return
	}

	taskRequest := &performerV1.TaskRequest{
		TaskId:  []byte("test-lvr-task-id"),
		Payload: payloadBytes,
	}

	err = performer.ValidateTask(taskRequest)
	if err != nil {
		t.Errorf("ValidateTask failed: %v", err)
	}

	resp, err := performer.HandleTask(taskRequest)
	if err != nil {
		t.Errorf("HandleTask failed: %v", err)
	}

	t.Logf("Response: %v", resp)
}

func Test_EigenLVRTaskTypes(t *testing.T) {
	logger, err := zap.NewDevelopment()
	if err != nil {
		t.Errorf("Failed to create logger: %v", err)
	}

	performer := NewEigenLVRPerformer(logger)

	testCases := []struct {
		name     string
		taskType TaskType
		params   map[string]interface{}
	}{
		{
			name:     "LVR Monitoring Task",
			taskType: TaskTypeLVRMonitoring,
			params: map[string]interface{}{
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
				"token0":       "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
				"token1":       "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
				"threshold":    50.0,
			},
		},
		{
			name:     "Auction Creation Task",
			taskType: TaskTypeAuctionCreation,
			params: map[string]interface{}{
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
				"lvr_amount":   "1000000000000000000",
				"duration":     12.0,
				"is_private":   false,
			},
		},
		{
			name:     "Bid Validation Task",
			taskType: TaskTypeBidValidation,
			params: map[string]interface{}{
				"auction_id":    "test-auction",
				"bidder":        "0xbidder123456789abcdef123456789abcdef1234",
				"bid_amount":    "1500000000000000000",
				"bid_signature": "0x1234567890abcdef",
				"min_bid":       "1000000000000000000",
			},
		},
		{
			name:     "Settlement Task",
			taskType: TaskTypeSettlement,
			params: map[string]interface{}{
				"auction_id":   "test-auction",
				"winner":       "0xwinner123456789abcdef123456789abcdef1234",
				"winning_bid":  "1500000000000000000",
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
			},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// Create task payload
			payload := TaskPayload{
				Type:       tc.taskType,
				Parameters: tc.params,
			}

			payloadBytes, err := json.Marshal(payload)
			if err != nil {
				t.Errorf("Failed to marshal payload: %v", err)
				return
			}

			taskRequest := &performerV1.TaskRequest{
				TaskId:  []byte("test-task-" + string(tc.taskType)),
				Payload: payloadBytes,
			}

			// Test validation
			err = performer.ValidateTask(taskRequest)
			if err != nil {
				t.Errorf("ValidateTask failed for %s: %v", tc.name, err)
				return
			}

			// Test handling
			resp, err := performer.HandleTask(taskRequest)
			if err != nil {
				t.Errorf("HandleTask failed for %s: %v", tc.name, err)
				return
			}

			if resp == nil {
				t.Errorf("HandleTask returned nil response for %s", tc.name)
				return
			}

			if len(resp.Result) == 0 {
				t.Errorf("HandleTask returned empty result for %s", tc.name)
				return
			}

			t.Logf("%s completed successfully with result: %s", tc.name, string(resp.Result))
		})
	}
}

func Test_TaskPayloadParsing(t *testing.T) {
	// Test payload parsing functionality
	testPayload := TaskPayload{
		Type: TaskTypeLVRMonitoring,
		Parameters: map[string]interface{}{
			"pool_address": "0x1234567890abcdef",
			"threshold":    1000,
		},
	}

	payloadBytes, err := json.Marshal(testPayload)
	if err != nil {
		t.Errorf("Failed to marshal test payload: %v", err)
		return
	}

	taskRequest := &performerV1.TaskRequest{
		TaskId:  []byte("parse-test"),
		Payload: payloadBytes,
	}

	parsedPayload, err := parseTaskPayload(taskRequest)
	if err != nil {
		t.Errorf("Failed to parse task payload: %v", err)
		return
	}

	if parsedPayload.Type != TaskTypeLVRMonitoring {
		t.Errorf("Expected task type %s, got %s", TaskTypeLVRMonitoring, parsedPayload.Type)
	}

	if parsedPayload.Parameters["threshold"] != float64(1000) {
		t.Errorf("Expected threshold 1000, got %v", parsedPayload.Parameters["threshold"])
	}

	t.Logf("Payload parsing test successful: %+v", parsedPayload)
}

// =============================================================================
// COMPREHENSIVE EIGENLVR TEST SUITE
// =============================================================================

// TestNewEigenLVRPerformer tests the creation of a new EigenLVR performer
func TestNewEigenLVRPerformer(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	if performer == nil {
		t.Fatal("Expected performer to be created, got nil")
	}

	if performer.logger != logger {
		t.Error("Expected logger to be set correctly")
	}

	if performer.lvrThreshold != 50 {
		t.Errorf("Expected LVR threshold to be 50, got %d", performer.lvrThreshold)
	}

	if performer.minProfit != 25 {
		t.Errorf("Expected min profit to be 25, got %d", performer.minProfit)
	}

	if performer.priceCache == nil {
		t.Error("Expected price cache to be initialized")
	}

	if performer.ethClients == nil {
		t.Error("Expected eth clients map to be initialized")
	}
}

// TestTaskValidation tests comprehensive task validation
func TestTaskValidation(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	tests := []struct {
		name    string
		payload *TaskPayload
		wantErr bool
	}{
		{
			name: "valid LVR monitoring task",
			payload: &TaskPayload{
				Type: TaskTypeLVRMonitoring,
				Parameters: map[string]interface{}{
					"pool_address": "0x123456789abcdef123456789abcdef1234567890",
					"token0":       "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
					"token1":       "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
					"threshold":    50.0,
				},
			},
			wantErr: false,
		},
		{
			name: "invalid LVR monitoring task - missing pool_address",
			payload: &TaskPayload{
				Type: TaskTypeLVRMonitoring,
				Parameters: map[string]interface{}{
					"token0":    "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
					"token1":    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
					"threshold": 50.0,
				},
			},
			wantErr: true,
		},
		{
			name: "valid cross-chain price sync task",
			payload: &TaskPayload{
				Type: TaskTypeCrossChainPriceSync,
				Parameters: map[string]interface{}{
					"token0":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
					"token1":        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
					"target_chains": []interface{}{1.0, 42161.0, 10.0},
				},
			},
			wantErr: false,
		},
		{
			name: "invalid cross-chain task - empty target chains",
			payload: &TaskPayload{
				Type: TaskTypeCrossChainPriceSync,
				Parameters: map[string]interface{}{
					"token0":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
					"token1":        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
					"target_chains": []interface{}{},
				},
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := performer.validateTaskPayload(tt.payload)

			if tt.wantErr {
				if err == nil {
					t.Error("Expected validation error but got nil")
				}
			} else {
				if err != nil {
					t.Errorf("Unexpected validation error: %v", err)
				}
			}
		})
	}
}

// Helper method for testing validation
func (elp *EigenLVRPerformer) validateTaskPayload(payload *TaskPayload) error {
	switch payload.Type {
	case TaskTypeLVRMonitoring:
		return elp.validateLVRMonitoringTask(payload)
	case TaskTypeCrossChainPriceSync:
		return elp.validateCrossChainPriceSyncTask(payload)
	case TaskTypeLVROpportunityDetection:
		return elp.validateLVROpportunityDetectionTask(payload)
	case TaskTypeAuctionCreation:
		return elp.validateAuctionCreationTask(payload)
	case TaskTypePrivateAuctionSetup:
		return elp.validatePrivateAuctionSetupTask(payload)
	case TaskTypeBidValidation:
		return elp.validateBidValidationTask(payload)
	case TaskTypeFHEBidProcessing:
		return elp.validateFHEBidProcessingTask(payload)
	case TaskTypeSettlement:
		return elp.validateSettlementTask(payload)
	case TaskTypeMEVDistribution:
		return elp.validateMEVDistributionTask(payload)
	case TaskTypeCrossChainExecution:
		return elp.validateCrossChainExecutionTask(payload)
	default:
		return fmt.Errorf("unsupported task type: %s", payload.Type)
	}
}

// TestCalculateDeviation tests price deviation calculation
func TestCalculateDeviation(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	tests := []struct {
		name     string
		price1   string
		price2   string
		expected uint64
	}{
		{
			name:     "identical prices",
			price1:   "1000000000000000000000", // $1000
			price2:   "1000000000000000000000", // $1000
			expected: 0,
		},
		{
			name:     "5% deviation",
			price1:   "1000000000000000000000", // $1000
			price2:   "1050000000000000000000", // $1050
			expected: 500, // 5% = 500 BPS
		},
		{
			name:     "zero price handling",
			price1:   "0",
			price2:   "1000000000000000000000",
			expected: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			price1 := new(big.Int)
			price1.SetString(tt.price1, 10)
			price2 := new(big.Int)
			price2.SetString(tt.price2, 10)

			deviation := performer.calculateDeviation(price1, price2)

			if deviation != tt.expected {
				t.Errorf("Expected deviation %d, got %d", tt.expected, deviation)
			}
		})
	}
}

// TestDetectCrossChainLVR tests cross-chain LVR detection
func TestDetectCrossChainLVR(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	token0 := "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d"
	token1 := "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

	opportunities := performer.detectCrossChainLVR(1, token0, token1)

	if len(opportunities) == 0 {
		t.Error("Expected cross-chain opportunities to be detected")
		return
	}

	// Verify each opportunity
	for _, opp := range opportunities {
		if !opp.IsCrossChain {
			t.Error("Expected cross-chain opportunity")
		}

		if opp.SourceChain == opp.TargetChain {
			t.Error("Source and target chains should be different")
		}

		if opp.ProfitBPS < performer.minProfit {
			t.Errorf("Expected profit BPS >= %d, got %d", performer.minProfit, opp.ProfitBPS)
		}

		if opp.Volume.Cmp(big.NewInt(0)) <= 0 {
			t.Error("Expected positive volume")
		}
	}
}

// TestTaskHandlers tests all task handler functions
func TestTaskHandlers(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	// Test LVR monitoring handler
	t.Run("LVR Monitoring Handler", func(t *testing.T) {
		payload := &TaskPayload{
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

		taskRequest := &performerV1.TaskRequest{
			TaskId:  []byte("test-lvr-monitoring"),
			Payload: []byte("test-payload"),
		}

		result, err := performer.handleLVRMonitoring(taskRequest, payload)
		if err != nil {
			t.Errorf("Unexpected error in LVR monitoring handler: %v", err)
		}

		// Verify result is valid JSON
		var resultData map[string]interface{}
		if err := json.Unmarshal(result, &resultData); err != nil {
			t.Errorf("Result is not valid JSON: %v", err)
		}

		// Check required fields
		requiredFields := []string{"pool_address", "chain_id", "pool_price", "oracle_price", "deviation_bps"}
		for _, field := range requiredFields {
			if _, exists := resultData[field]; !exists {
				t.Errorf("Missing required field in result: %s", field)
			}
		}
	})

	// Test settlement handler
	t.Run("Settlement Handler", func(t *testing.T) {
		payload := &TaskPayload{
			Type: TaskTypeSettlement,
			Parameters: map[string]interface{}{
				"auction_id":   "test-auction-123",
				"winner":       "0xabcdef123456789abcdef123456789abcdef1234",
				"winning_bid":  "1500000000000000000",
				"pool_address": "0x123456789abcdef123456789abcdef1234567890",
			},
			ChainID:     1,
			BlockNumber: 12345678,
			Timestamp:   time.Now().Unix(),
		}

		taskRequest := &performerV1.TaskRequest{
			TaskId:  []byte("test-settlement"),
			Payload: []byte("test-payload"),
		}

		result, err := performer.handleSettlement(taskRequest, payload)
		if err != nil {
			t.Errorf("Unexpected error in settlement handler: %v", err)
		}

		// Verify MEV distribution calculations
		var resultData map[string]interface{}
		if err := json.Unmarshal(result, &resultData); err != nil {
			t.Errorf("Result is not valid JSON: %v", err)
		}

		// Check LP amount (should be 85% of winning bid)
		winningBid := new(big.Int)
		winningBid.SetString("1500000000000000000", 10)
		expectedLPAmount := new(big.Int).Mul(winningBid, big.NewInt(8500))
		expectedLPAmount = expectedLPAmount.Div(expectedLPAmount, big.NewInt(10000))

		if lpAmountStr, exists := resultData["lp_amount"].(string); exists {
			lpAmount := new(big.Int)
			lpAmount.SetString(lpAmountStr, 10)
			if lpAmount.Cmp(expectedLPAmount) != 0 {
				t.Errorf("Expected LP amount %s, got %s", expectedLPAmount.String(), lpAmount.String())
			}
		} else {
			t.Error("Missing lp_amount in settlement result")
		}
	})
}

// TestCrossChainPriceSync tests cross-chain price synchronization
func TestCrossChainPriceSync(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	payload := &TaskPayload{
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

	taskRequest := &performerV1.TaskRequest{
		TaskId:  []byte("test-cross-chain-sync"),
		Payload: []byte("test-payload"),
	}

	result, err := performer.handleCrossChainPriceSync(taskRequest, payload)
	if err != nil {
		t.Errorf("Unexpected error in cross-chain price sync: %v", err)
	}

	// Verify result structure
	var resultData map[string]interface{}
	if err := json.Unmarshal(result, &resultData); err != nil {
		t.Errorf("Result is not valid JSON: %v", err)
	}

	// Check that prices were synced for multiple chains
	if chainsSynced, exists := resultData["chains_synced"].(float64); !exists || chainsSynced < 1 {
		t.Error("Expected chains_synced to be > 0")
	}

	// Check token pair format
	if tokenPair, exists := resultData["token_pair"].(string); !exists || tokenPair == "" {
		t.Error("Missing or empty token_pair in result")
	}
}

// BenchmarkLVRDetection benchmarks LVR detection performance
func BenchmarkLVRDetection(b *testing.B) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	poolAddress := "0x123456789abcdef123456789abcdef1234567890"
	token0 := "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d"
	token1 := "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = performer.detectSingleChainLVR(1, poolAddress, token0, token1)
	}
}

// TestAllTaskTypes tests all supported task types
func TestAllTaskTypes(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	performer := NewEigenLVRPerformer(logger)

	taskTypes := []TaskType{
		TaskTypeLVRMonitoring,
		TaskTypeCrossChainPriceSync,
		TaskTypeLVROpportunityDetection,
		TaskTypeAuctionCreation,
		TaskTypePrivateAuctionSetup,
		TaskTypeBidValidation,
		TaskTypeFHEBidProcessing,
		TaskTypeSettlement,
		TaskTypeMEVDistribution,
		TaskTypeCrossChainExecution,
	}

	for _, taskType := range taskTypes {
		t.Run(string(taskType), func(t *testing.T) {
			// Create minimal valid parameters for each task type
			params := getMinimalValidParams(taskType)
			
			payload := &TaskPayload{
				Type:        taskType,
				Parameters:  params,
				ChainID:     1,
				BlockNumber: 12345678,
				Timestamp:   time.Now().Unix(),
			}

			// Test validation
			err := performer.validateTaskPayload(payload)
			if err != nil {
				t.Errorf("Validation failed for task type %s: %v", taskType, err)
			}
		})
	}
}

// Helper function to get minimal valid parameters for each task type
func getMinimalValidParams(taskType TaskType) map[string]interface{} {
	switch taskType {
	case TaskTypeLVRMonitoring, TaskTypeLVROpportunityDetection:
		return map[string]interface{}{
			"pool_address": "0x123456789abcdef123456789abcdef1234567890",
			"token0":       "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
			"token1":       "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			"threshold":    50.0,
		}
	case TaskTypeCrossChainPriceSync:
		return map[string]interface{}{
			"token0":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
			"token1":        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
			"target_chains": []interface{}{1.0, 42161.0},
		}
	case TaskTypeAuctionCreation:
		return map[string]interface{}{
			"pool_address": "0x123456789abcdef123456789abcdef1234567890",
			"lvr_amount":   "1000000000000000000",
			"duration":     12.0,
			"is_private":   false,
		}
	case TaskTypePrivateAuctionSetup:
		return map[string]interface{}{
			"auction_id":     "test-auction",
			"min_bid":        "1000000000000000000",
			"reserve_amount": "1100000000000000000",
			"duration":       12.0,
		}
	case TaskTypeBidValidation:
		return map[string]interface{}{
			"auction_id":    "test-auction",
			"bidder":        "0xbidder123456789abcdef123456789abcdef1234",
			"bid_amount":    "1500000000000000000",
			"bid_signature": "0x1234567890abcdef",
			"min_bid":       "1000000000000000000",
		}
	case TaskTypeFHEBidProcessing:
		return map[string]interface{}{
			"auction_id":    "test-auction",
			"encrypted_bid": "0x"+fmt.Sprintf("%064s", "encrypted"),
			"bidder":        "0xbidder123456789abcdef123456789abcdef1234",
		}
	case TaskTypeSettlement:
		return map[string]interface{}{
			"auction_id":   "test-auction",
			"winner":       "0xwinner123456789abcdef123456789abcdef1234",
			"winning_bid":  "1500000000000000000",
			"pool_address": "0x123456789abcdef123456789abcdef1234567890",
		}
	case TaskTypeMEVDistribution:
		return map[string]interface{}{
			"total_mev":     "1500000000000000000",
			"pool_address":  "0x123456789abcdef123456789abcdef1234567890",
			"lp_addresses":  []interface{}{"0xlp123456789abcdef123456789abcdef12345678"},
		}
	case TaskTypeCrossChainExecution:
		return map[string]interface{}{
			"source_chain": 1.0,
			"target_chain": 42161.0,
			"token":        "0xA0b86a33E6441c8A0E68C0A12e5AA2Ba7B5bF37d",
			"amount":       "1000000000000000000",
		}
	default:
		return map[string]interface{}{}
	}
}