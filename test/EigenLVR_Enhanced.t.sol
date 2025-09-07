// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {FHE, InEuint128, InEuint64} from "@fhenixprotocol/cofhe-contracts/FHE.sol";
import {CoFheTest} from "../context/cofhe-mock-contracts/contracts/CoFheTest.sol";

import {EigenLVR_Enhanced} from "../src/EigenLVR_Enhanced.sol";
import {CrossChainPriceMonitor} from "../src/crosschain/CrossChainPriceMonitor.sol";
import {PrivateAuctionManager} from "../src/privacy/PrivateAuctionManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../src/interfaces/IPriceOracle.sol";

// Mock contracts for testing
contract MockPoolManager {
    function getHookPermissions(address) external pure returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }
}

contract MockAVSDirectory {
    mapping(address => mapping(address => bool)) public operatorRegistrations;
    
    function registerOperatorToAVS(address operator, bytes calldata) external {
        operatorRegistrations[msg.sender][operator] = true;
    }
    
    function isOperatorRegistered(address avs, address operator) external view returns (bool) {
        return operatorRegistrations[avs][operator];
    }
    
    function getOperatorStake(address, address) external pure returns (uint256) {
        return 1000 ether;
    }
}

contract MockPriceOracle {
    mapping(bytes32 => uint256) public prices;
    mapping(bytes32 => uint256) public timestamps;
    
    function setPrice(Currency token0, Currency token1, uint256 price) external {
        bytes32 key = keccak256(abi.encode(token0, token1));
        prices[key] = price;
        timestamps[key] = block.timestamp;
    }
    
    function getPrice(Currency token0, Currency token1) external view returns (uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return prices[key] > 0 ? prices[key] : 3000e18; // Default $3000
    }
    
    function getPriceWithTimestamp(Currency token0, Currency token1) external view returns (uint256, uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return (prices[key] > 0 ? prices[key] : 3000e18, timestamps[key]);
    }
    
    function isPriceFresh(Currency, Currency, uint256) external pure returns (bool) {
        return true;
    }
    
    function getPriceConfidence(Currency, Currency) external pure returns (uint256) {
        return 10000;
    }
}

/**
 * @title EigenLVR_Enhanced Test Suite
 * @notice Comprehensive tests for the production-ready enhanced system
 */
contract EigenLVR_EnhancedTest is Test, CoFheTest {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    
    /*//////////////////////////////////////////////////////////////
                                CONTRACTS
    //////////////////////////////////////////////////////////////*/
    
    EigenLVR_Enhanced public hook;
    CrossChainPriceMonitor public priceMonitor;
    PrivateAuctionManager public auctionManager;
    
    MockPoolManager public poolManager;
    MockAVSDirectory public avsDirectory;
    MockPriceOracle public priceOracle;
    
    /*//////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////*/
    
    address constant ALICE = 0x1111111111111111111111111111111111111111;
    address constant BOB = 0x2222222222222222222222222222222222222222;
    address constant CHARLIE = 0x3333333333333333333333333333333333333333;
    address constant FEE_RECIPIENT = 0x4444444444444444444444444444444444444444;
    
    Currency constant CURRENCY0 = Currency.wrap(0x5555555555555555555555555555555555555555);
    Currency constant CURRENCY1 = Currency.wrap(0x6666666666666666666666666666666666666666);
    
    function setUp() public {
        // Deploy mock contracts
        poolManager = new MockPoolManager();
        avsDirectory = new MockAVSDirectory();
        priceOracle = new MockPriceOracle();
        
        // Deploy enhanced system
        priceMonitor = new CrossChainPriceMonitor();
        auctionManager = new PrivateAuctionManager();
        
        hook = new EigenLVR_Enhanced(
            IPoolManager(address(poolManager)),
            IAVSDirectory(address(avsDirectory)),
            IPriceOracle(address(priceOracle)),
            address(priceMonitor),
            address(auctionManager),
            FEE_RECIPIENT,
            50 // 0.5% threshold
        );
        
        // Setup permissions
        auctionManager.authorizeOperator(address(hook), true);
        priceMonitor.setAuthorizedUpdater(address(this), true);
        
        // Fund test accounts
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CHARLIE, 100 ether);
        
        // Setup initial cross-chain prices
        _setupCrossChainPrices();
    }
    
    function _setupCrossChainPrices() internal {
        // Setup varied prices across chains
        priceMonitor.updatePrice(1, CURRENCY0, CURRENCY1, 3000e18, 10000);     // Ethereum: $3000
        priceMonitor.updatePrice(42161, CURRENCY0, CURRENCY1, 3005e18, 9500);  // Arbitrum: $3005
        priceMonitor.updatePrice(10, CURRENCY0, CURRENCY1, 2998e18, 9200);     // Optimism: $2998
        priceMonitor.updatePrice(137, CURRENCY0, CURRENCY1, 3010e18, 8800);    // Polygon: $3010
        priceMonitor.updatePrice(8453, CURRENCY0, CURRENCY1, 3002e18, 9600);   // Base: $3002
    }
    
    /*//////////////////////////////////////////////////////////////
                            BASIC TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testHookPermissions() public {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
        assertTrue(permissions.beforeAddLiquidity, "beforeAddLiquidity should be enabled");
        assertTrue(permissions.beforeRemoveLiquidity, "beforeRemoveLiquidity should be enabled");
        assertTrue(permissions.beforeSwap, "beforeSwap should be enabled");
        assertTrue(permissions.afterSwap, "afterSwap should be enabled");
        
        // Should NOT be enabled (focused approach)
        assertFalse(permissions.beforeInitialize, "beforeInitialize should be disabled");
        assertFalse(permissions.afterAddLiquidity, "afterAddLiquidity should be disabled");
        assertFalse(permissions.beforeDonate, "beforeDonate should be disabled");
    }
    
    function testAfterInitialize() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        vm.prank(address(poolManager));
        bytes4 selector = hook.afterInitialize(address(this), key, 1e18, 0);
        
        assertEq(selector, BaseHook.afterInitialize.selector, "Should return correct selector");
    }
    
    /*//////////////////////////////////////////////////////////////
                        CROSS-CHAIN PRICE TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testCrossChainPriceMonitor() public {
        // Test basic price retrieval
        uint256 bestPrice = priceMonitor.getBestPrice(CURRENCY0, CURRENCY1);
        assertTrue(bestPrice > 0, "Should return valid price");
        
        // Test price freshness
        assertTrue(priceMonitor.isPriceFresh(1, CURRENCY0, CURRENCY1), "Price should be fresh");
        
        // Test supported chains
        uint256[] memory chains = priceMonitor.getSupportedChains();
        assertTrue(chains.length > 0, "Should have supported chains");
        
        console2.log("Best cross-chain price:", bestPrice);
        console2.log("Supported chains:", chains.length);
    }
    
    function testCrossChainPriceAggregation() public {
        // Test weighted aggregation
        uint256 bestPrice = priceMonitor.getBestPrice(CURRENCY0, CURRENCY1);
        
        // Should be weighted average considering confidence scores
        assertTrue(bestPrice >= 2998e18, "Price should be >= minimum");
        assertTrue(bestPrice <= 3010e18, "Price should be <= maximum");
        
        // Test better pricing detection
        uint256 localPrice = 2900e18; // Lower than cross-chain prices
        (bool hasBetter, uint256 betterPrice) = priceMonitor.hasBetterCrossChainPrice(
            CURRENCY0, CURRENCY1, localPrice, 100 // 1% improvement threshold
        );
        
        assertTrue(hasBetter, "Should detect better cross-chain price");
        assertTrue(betterPrice > localPrice, "Better price should be higher");
        
        console2.log("Local price:", localPrice);
        console2.log("Better cross-chain price:", betterPrice);
    }
    
    /*//////////////////////////////////////////////////////////////
                        PRIVATE AUCTION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testPrivateAuctionCreation() public {
        bytes32 auctionId = keccak256("test-private-auction");
        
        InEuint128 memory encMinBid = createInEuint128(uint128(1e18), ALICE);
        InEuint128 memory encReserve = createInEuint128(uint128(5e18), ALICE);
        InEuint64 memory encDuration = createInEuint64(uint64(300), ALICE);
        
        vm.prank(ALICE);
        auctionManager.createPrivateAuction(auctionId, encMinBid, encReserve, encDuration);
        
        // Verify auction was created
        (address seller, bool isActive, uint256 deadline, uint256 bidCount) = 
            auctionManager.getAuctionInfo(auctionId);
        
        assertEq(seller, ALICE, "Seller should be Alice");
        assertTrue(isActive, "Auction should be active");
        assertGt(deadline, block.timestamp, "Deadline should be in future");
        assertEq(bidCount, 0, "Should start with no bids");
        
        console2.log("Private auction created by:", seller);
        console2.log("Auction deadline:", deadline);
    }
    
    function testPrivateAuctionBidding() public {
        bytes32 auctionId = keccak256("test-bidding-auction");
        
        // Create auction first
        vm.prank(ALICE);
        InEuint128 memory encMinBid = createInEuint128(uint128(1e18), ALICE);
        InEuint128 memory encReserve = createInEuint128(uint128(5e18), ALICE);
        InEuint64 memory encDuration = createInEuint64(uint64(300), ALICE);
        auctionManager.createPrivateAuction(auctionId, encMinBid, encReserve, encDuration);
        
        // Submit encrypted bid
        vm.prank(BOB);
        InEuint128 memory encBid = createInEuint128(uint128(2e18), BOB);
        auctionManager.submitEncryptedBid(auctionId, encBid);
        
        // Verify bid was submitted
        assertTrue(auctionManager.hasBid(auctionId, BOB), "Bob should have submitted bid");
        
        // Check bid count
        (,, uint256 bidCount) = auctionManager.getAuctionInfo(auctionId);
        assertEq(bidCount, 1, "Should have one bid");
        
        console2.log("Bid submitted by:", BOB);
        console2.log("Total bids:", bidCount);
    }
    
    /*//////////////////////////////////////////////////////////////
                        ENHANCED LVR DETECTION
    //////////////////////////////////////////////////////////////*/
    
    function testEnhancedLVRDetection() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Set local oracle price lower than cross-chain
        priceOracle.setPrice(CURRENCY0, CURRENCY1, 2950e18); // $2950
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 10e18, // 10 ETH swap
            sqrtPriceLimitX96: 0
        });
        
        // Should detect enhanced LVR due to cross-chain price difference
        vm.prank(address(poolManager));
        (bytes4 selector,,) = hook.beforeSwap(address(this), key, params, "");
        
        assertEq(selector, BaseHook.beforeSwap.selector, "Should handle swap");
        
        console2.log("Enhanced LVR detection test completed");
    }
    
    function testStandardVsPrivateAuction() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 0
        });
        
        // Test standard auction (no hookData)
        vm.prank(address(poolManager));
        (bytes4 selector1,,) = hook.beforeSwap(address(this), key, params, "");
        assertEq(selector1, BaseHook.beforeSwap.selector);
        
        // Test private auction (with hookData requesting privacy)
        bytes memory hookData = abi.encode(true); // Request private auction
        vm.prank(address(poolManager));
        (bytes4 selector2,,) = hook.beforeSwap(address(this), key, params, hookData);
        assertEq(selector2, BaseHook.beforeSwap.selector);
        
        console2.log("Both standard and private auctions work");
    }
    
    /*//////////////////////////////////////////////////////////////
                        LIQUIDITY TRACKING TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testLiquidityTracking() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        PoolId poolId = key.toId();
        
        // Test adding liquidity
        ModifyLiquidityParams memory addParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18,
            salt: bytes32(0)
        });
        
        vm.prank(address(poolManager));
        hook.beforeAddLiquidity(ALICE, key, addParams, "");
        
        // Verify tracking
        assertEq(hook.lpLiquidity(poolId, ALICE), 1000e18, "Should track Alice's liquidity");
        assertEq(hook.totalLiquidity(poolId), 1000e18, "Should track total liquidity");
        
        // Test removing liquidity
        ModifyLiquidityParams memory removeParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: -500e18,
            salt: bytes32(0)
        });
        
        vm.prank(address(poolManager));
        hook.beforeRemoveLiquidity(ALICE, key, removeParams, "");
        
        // Verify tracking after removal
        assertEq(hook.lpLiquidity(poolId, ALICE), 500e18, "Should update Alice's liquidity");
        assertEq(hook.totalLiquidity(poolId), 500e18, "Should update total liquidity");
        
        console2.log("Liquidity tracking working correctly");
    }
    
    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testOperatorAuthorization() public {
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized initially");
        
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized after removal");
    }
    
    function testLVRThresholdUpdate() public {
        uint256 newThreshold = 100; // 1%
        
        hook.setLVRThreshold(newThreshold);
        assertEq(hook.lvrThreshold(), newThreshold, "Threshold should be updated");
        
        // Test threshold too high
        vm.expectRevert("Threshold too high");
        hook.setLVRThreshold(2000); // 20% - too high
    }
    
    function testOnlyOwnerFunctions() public {
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setOperatorAuthorization(BOB, true);
        
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setLVRThreshold(100);
    }
    
    /*//////////////////////////////////////////////////////////////
                        INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testFullEnhancedWorkflow() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // 1. Initialize pool with FHE setup
        vm.prank(address(poolManager));
        hook.afterInitialize(address(this), key, 1e18, 0);
        
        // 2. Add liquidity and track positions
        ModifyLiquidityParams memory liquidityParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18,
            salt: bytes32(0)
        });
        
        vm.prank(address(poolManager));
        hook.beforeAddLiquidity(ALICE, key, liquidityParams, "");
        
        // 3. Create cross-chain price discrepancy
        priceOracle.setPrice(CURRENCY0, CURRENCY1, 2900e18); // Local: $2900
        // Cross-chain prices already set to ~$3000 in setUp
        
        // 4. Execute swap that triggers enhanced LVR detection
        SwapParams memory swapParams = SwapParams({
            zeroForOne: true,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 0
        });
        
        vm.prank(address(poolManager));
        (bytes4 selector,,) = hook.beforeSwap(address(this), key, swapParams, "");
        
        // 5. Process after swap
        vm.prank(address(poolManager));
        (bytes4 afterSelector,) = hook.afterSwap(address(this), key, swapParams, BalanceDelta.wrap(0), "");
        
        assertEq(selector, BaseHook.beforeSwap.selector, "Should handle enhanced swap");
        assertEq(afterSelector, BaseHook.afterSwap.selector, "Should handle after swap");
        
        console2.log("Full enhanced workflow completed successfully");
    }
    
    /*//////////////////////////////////////////////////////////////
                        PERFORMANCE TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testGasUsage() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        // Measure gas for standard auction
        uint256 gasStart = gasleft();
        vm.prank(address(poolManager));
        hook.beforeSwap(address(this), key, params, "");
        uint256 gasUsed = gasStart - gasleft();
        
        console2.log("Gas used for standard auction:", gasUsed);
        assertTrue(gasUsed < 500000, "Should use reasonable gas");
        
        // Measure gas for private auction
        bytes memory privateHookData = abi.encode(true);
        gasStart = gasleft();
        vm.prank(address(poolManager));
        hook.beforeSwap(address(this), key, params, privateHookData);
        uint256 privateGasUsed = gasStart - gasleft();
        
        console2.log("Gas used for private auction:", privateGasUsed);
        assertTrue(privateGasUsed < 800000, "Private auction should use reasonable gas");
    }
    
    function testReceiveETH() public {
        uint256 balanceBefore = address(hook).balance;
        
        (bool success,) = payable(address(hook)).call{value: 1 ether}("");
        assertTrue(success, "Should accept ETH");
        
        assertEq(address(hook).balance, balanceBefore + 1 ether, "Balance should increase");
    }
}

// Additional interface needed for compilation
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";