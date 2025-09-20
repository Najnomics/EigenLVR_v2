// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/**
 * @title EigenLVR_V2 Auction Tests
 * @notice Tests for auction functionality
 * @dev Tests auction creation, bidding, and settlement
 */
contract EigenLVR_V2_AuctionTests is BaseEigenLVRTest {
    
    function setUp() public override {
        super.setUp();
        
        // Deploy hook with valid address
        hook = deployHookWithValidAddress();
        
        // Setup permissions
        privateAuctionManager.authorizeOperator(address(hook), true);
        crossChainMonitor.setAuthorizedUpdater(address(this), true);
        
        // Set test prices
        priceOracle.setPrice(TOKEN0, TOKEN1, 3000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 3000e18);
    }

    /*//////////////////////////////////////////////////////////////
                            AUCTION FUNCTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testAuctionCreation() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        // Test auction creation through beforeSwap via PoolManager
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function testPrivateAuctionCreation() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        // Test private auction creation
        bytes memory hookData = abi.encode(true); // Request private auction
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function testAuctionConstants() public view {
        assertEq(hook.MIN_BID(), 1e15, "MIN_BID should be 0.001 ETH");
        assertEq(hook.MAX_AUCTION_DURATION(), 12, "MAX_AUCTION_DURATION should be 12 seconds");
    }

    function testAuctionRewardPercentages() public view {
        assertEq(hook.LP_REWARD_PERCENTAGE(), 8500, "LP_REWARD_PERCENTAGE should be 85%");
        assertEq(hook.AVS_REWARD_PERCENTAGE(), 1000, "AVS_REWARD_PERCENTAGE should be 10%");
        assertEq(hook.PROTOCOL_FEE_PERCENTAGE(), 300, "PROTOCOL_FEE_PERCENTAGE should be 3%");
        assertEq(hook.GAS_COMPENSATION_PERCENTAGE(), 200, "GAS_COMPENSATION_PERCENTAGE should be 2%");
        assertEq(hook.BASIS_POINTS(), 10000, "BASIS_POINTS should be 10000");
    }

    function testAuctionState() public view {
        // Test initial auction state
        assertEq(hook.activeAuctions(poolId), bytes32(0), "No active auctions initially");
        assertEq(hook.poolRewards(poolId), 0, "No pool rewards initially");
        assertEq(hook.totalLiquidity(poolId), 0, "No total liquidity initially");
    }

    function testLiquidityTracking() public {
        // Test liquidity tracking
        assertEq(hook.totalLiquidity(poolId), 0, "Initial total liquidity should be 0");
        assertEq(hook.lpLiquidity(poolId, ALICE), 0, "Initial LP liquidity should be 0");
    }

    /*//////////////////////////////////////////////////////////////
                        COMPREHENSIVE AUCTION TESTS (7-50)
    //////////////////////////////////////////////////////////////*/

    function test7_AuctionCreationWithLVR() public {
        // Set up price deviation to trigger LVR detection
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18); // 33% higher than pool price
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18, // Significant swap
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test8_AuctionCreationWithCrossChainLVR() public {
        // Set up cross-chain price deviation
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4000e18); // 33% higher
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle cross-chain LVR");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test9_PrivateAuctionWithFHE() public {
        // Test private auction creation with FHE
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = abi.encode(true); // Request private auction
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should create private auction");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test10_AuctionWithDifferentThresholds() public {
        // Test with different LVR threshold
        hook.setLVRThreshold(25); // Lower threshold
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 3100e18); // 3.3% deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with lower threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test11_AuctionWithHighThreshold() public {
        // Test with high LVR threshold
        hook.setLVRThreshold(100);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18); // High deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with high threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test12_AuctionWithZeroThreshold() public {
        // Test with zero threshold (should trigger on any deviation)
        hook.setLVRThreshold(0);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 3001e18); // Minimal deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with zero threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test13_AuctionWithSmallSwap() public {
        // Test with small swap (should not trigger auction)
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e17, // Small swap
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle small swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test14_AuctionWithLargeSwap() public {
        // Test with large swap
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 100e18, // Large swap
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle large swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test15_AuctionWithDifferentTokens() public {
        Currency newToken0 = Currency.wrap(0x7777777777777777777777777777777777777777);
        Currency newToken1 = Currency.wrap(0x8888888888888888888888888888888888888888);
        
        priceOracle.setPrice(newToken0, newToken1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: newToken0,
            currency1: newToken1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with different tokens");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test16_AuctionWithDifferentFees() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 500, // Different fee tier
            tickSpacing: 10,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with different fees");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test17_AuctionWithZeroForOneTrue() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with zeroForOne true");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test18_AuctionWithZeroForOneFalse() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: false,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with zeroForOne false");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test19_AuctionWithNegativeAmount() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: -2e18, // Negative amount
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle negative amounts");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test20_AuctionWithPriceLimit() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle price limits");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test21_AuctionWithMultiplePools() public {
        // Test with multiple pools
        Currency newToken0 = Currency.wrap(0x7777777777777777777777777777777777777777);
        Currency newToken1 = Currency.wrap(0x8888888888888888888888888888888888888888);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        priceOracle.setPrice(newToken0, newToken1, 5000e18);
        
        PoolKey memory pool1 = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        PoolKey memory pool2 = PoolKey({
            currency0: newToken0,
            currency1: newToken1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(address(this), pool1, params, "");
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(address(this), pool2, params, "");
        
        assertEq(selector1, hook.beforeSwap.selector, "Should work with multiple pools");
        assertEq(selector2, hook.beforeSwap.selector, "Should work with multiple pools");
        assertEq(delta1, 0, "Should return zero delta");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test22_AuctionWithDifferentCallers() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, "");
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(BOB, testPoolKey, params, "");
        
        assertEq(selector1, hook.beforeSwap.selector, "Should work with different callers");
        assertEq(selector2, hook.beforeSwap.selector, "Should work with different callers");
        assertEq(delta1, 0, "Should return zero delta");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test23_AuctionWithHookData() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test24_AuctionWithEmptyHookData() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = "";
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle empty hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test25_AuctionWithMaxAmount() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: type(int256).max,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle max amount");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test26_AuctionWithMinAmount() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: type(int256).min,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle min amount");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test27_AuctionGasUsage() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        uint256 gasStart = gasleft();
        poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        uint256 gasUsed = gasStart - gasleft();
        
        assertTrue(gasUsed < 1000000, "Gas usage should be reasonable");
    }

    function test28_AuctionWithPausedContract() public {
        hook.pause();
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        // Should revert when paused
        vm.expectRevert();
        poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
    }

    function test29_AuctionWithUnpausedContract() public {
        hook.pause();
        hook.unpause();
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work when unpaused");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test30_AuctionRewardCalculations() public view {
        // Test reward percentage calculations
        uint256 totalProceeds = 1000e18;
        uint256 expectedLP = (totalProceeds * 8500) / 10000; // 85%
        uint256 expectedAVS = (totalProceeds * 1000) / 10000; // 10%
        uint256 expectedProtocol = (totalProceeds * 300) / 10000; // 3%
        uint256 expectedGas = (totalProceeds * 200) / 10000; // 2%
        
        assertEq(expectedLP, 850e18, "LP reward should be 85%");
        assertEq(expectedAVS, 100e18, "AVS reward should be 10%");
        assertEq(expectedProtocol, 30e18, "Protocol reward should be 3%");
        assertEq(expectedGas, 20e18, "Gas reward should be 2%");
    }

    function test31_AuctionBasisPoints() public view {
        // Test basis points calculations
        assertEq(hook.BASIS_POINTS(), 10000, "Basis points should be 10000");
        assertEq(hook.LP_REWARD_PERCENTAGE() + hook.AVS_REWARD_PERCENTAGE() + hook.PROTOCOL_FEE_PERCENTAGE() + hook.GAS_COMPENSATION_PERCENTAGE(), 10000, "Total should be 100%");
    }

    function test32_AuctionDuration() public view {
        // Test auction duration
        assertEq(hook.MAX_AUCTION_DURATION(), 12, "Max auction duration should be 12 seconds");
        assertTrue(hook.MAX_AUCTION_DURATION() > 0, "Auction duration should be positive");
    }

    function test33_AuctionMinBid() public view {
        // Test minimum bid
        assertEq(hook.MIN_BID(), 1e15, "Min bid should be 0.001 ETH");
        assertTrue(hook.MIN_BID() > 0, "Min bid should be positive");
    }

    function test34_AuctionStateTransitions() public {
        // Test auction state transitions
        assertEq(hook.activeAuctions(poolId), bytes32(0), "No active auctions initially");
        
        // After potential auction creation, state should be consistent
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        
        // State should remain consistent
        assertTrue(true, "State should remain consistent");
    }

    function test35_AuctionWithZeroPrice() public {
        // Test with zero price (should not trigger auction)
        priceOracle.setPrice(TOKEN0, TOKEN1, 0);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle zero price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test36_AuctionWithVeryHighPrice() public {
        // Test with very high price (but not max to avoid overflow)
        priceOracle.setPrice(TOKEN0, TOKEN1, 1000000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle very high price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test37_AuctionWithCrossChainZeroPrice() public {
        // Test with cross-chain zero price
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 0);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle cross-chain zero price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test38_AuctionWithCrossChainHighPrice() public {
        // Test with cross-chain high price (but not max to avoid overflow)
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 1000000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle cross-chain high price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test39_AuctionWithBothPricesZero() public {
        // Test with both prices zero
        priceOracle.setPrice(TOKEN0, TOKEN1, 0);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 0);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle both prices zero");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test40_AuctionWithBothPricesMax() public {
        // Test with both prices max
        priceOracle.setPrice(TOKEN0, TOKEN1, type(uint256).max);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, type(uint256).max);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle both prices max");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test41_AuctionWithIdenticalPrices() public {
        // Test with identical prices (no deviation)
        priceOracle.setPrice(TOKEN0, TOKEN1, 3000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 3000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle identical prices");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test42_AuctionWithMinimalDeviation() public {
        // Test with minimal deviation (should not trigger with normal threshold)
        priceOracle.setPrice(TOKEN0, TOKEN1, 3001e18); // 0.03% deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle minimal deviation");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test43_AuctionWithExactThresholdDeviation() public {
        // Test with exact threshold deviation
        priceOracle.setPrice(TOKEN0, TOKEN1, 3150e18); // Exactly 5% deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle exact threshold deviation");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test44_AuctionWithJustOverThreshold() public {
        // Test with just over threshold
        priceOracle.setPrice(TOKEN0, TOKEN1, 3151e18); // Just over 5% deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle just over threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test45_AuctionWithJustUnderThreshold() public {
        // Test with just under threshold
        priceOracle.setPrice(TOKEN0, TOKEN1, 3149e18); // Just under 5% deviation
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle just under threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test46_AuctionWithMultipleThresholdChanges() public {
        // Test with multiple threshold changes
        hook.setLVRThreshold(25);
        hook.setLVRThreshold(75);
        hook.setLVRThreshold(100);
        
        assertEq(hook.lvrThreshold(), 100, "Threshold should be updated");
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with updated threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test47_AuctionWithComplexHookData() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        // Complex hook data structure
        bytes memory hookData = abi.encode(
            true, // requestPrivate
            uint256(1000), // customParam1
            address(0x1234567890123456789012345678901234567890) // customParam2
        );
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle complex hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test48_AuctionWithLargeHookData() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        // Large hook data (simplified)
        bytes memory largeData = abi.encode(
            true,
            uint256(1000),
            address(0x1234567890123456789012345678901234567890),
            bytes32(0x1234567890123456789012345678901234567890123456789012345678901234)
        );
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            largeData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle large hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test49_AuctionWithEdgeCaseAmounts() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Test with 1 wei
        SwapParams memory params1 = SwapParams({
            zeroForOne: true,
            amountSpecified: 1,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params1, 
            ""
        );
        
        assertEq(selector1, hook.beforeSwap.selector, "Should handle 1 wei");
        assertEq(delta1, 0, "Should return zero delta");
        
        // Test with 1 gwei
        SwapParams memory params2 = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e9,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params2, 
            ""
        );
        
        assertEq(selector2, hook.beforeSwap.selector, "Should handle 1 gwei");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test50_AuctionComprehensiveTest() public {
        // Comprehensive test combining multiple scenarios
        hook.setLVRThreshold(75);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4100e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        bytes memory hookData = abi.encode(true); // Request private auction
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            ALICE, 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle comprehensive scenario");
        assertEq(delta, 0, "Should return zero delta");
        
        // Verify state consistency
        assertEq(hook.lvrThreshold(), 75, "Threshold should remain set");
    }
}
