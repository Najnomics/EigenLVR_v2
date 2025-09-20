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
 * @title EigenLVR_V2 LVR Detection Tests
 * @notice Tests for LVR detection functionality
 * @dev Tests LVR detection, cross-chain price monitoring, and enhanced detection
 */
contract EigenLVR_V2_LVRDetectionTests is BaseEigenLVRTest {
    
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
                            LVR DETECTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testLVRDetection() public {
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

        // Test LVR detection through beforeSwap via PoolManager
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function testCrossChainPriceMonitoring() public {
        // Test cross-chain price monitoring
        assertEq(crossChainMonitor.getBestPrice(TOKEN0, TOKEN1), 3000e18, "Cross-chain price should be set");
    }

    function testLVRThreshold() public view {
        // Test LVR threshold
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be 50 basis points");
    }

    function testPriceOracle() public view {
        // Test price oracle
        assertEq(priceOracle.getPrice(TOKEN0, TOKEN1), 3000e18, "Price oracle should return correct price");
    }

    function testEnhancedLVRDetection() public {
        // Test enhanced LVR detection with cross-chain data
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

        // Test with different price scenarios
        priceOracle.setPrice(TOKEN0, TOKEN1, 3100e18); // 3.33% deviation
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 3200e18); // 6.67% deviation
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test5_LVRDetectionWithHighDeviation() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18); // 33% deviation
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle high deviation");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test6_LVRDetectionWithCrossChainDeviation() public {
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4000e18); // 33% deviation
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle cross-chain deviation");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test7_LVRDetectionWithZeroPrice() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle zero price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test8_LVRDetectionWithMaxPrice() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle max price");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test9_LVRDetectionWithMinimalDeviation() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle minimal deviation");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test10_LVRDetectionWithExactThreshold() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle exact threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test11_LVRDetectionWithDifferentThresholds() public {
        hook.setLVRThreshold(25);
        priceOracle.setPrice(TOKEN0, TOKEN1, 3075e18); // 2.5% deviation
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different thresholds");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test12_LVRDetectionWithZeroThreshold() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with zero threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test13_LVRDetectionWithMaxThreshold() public {
        hook.setLVRThreshold(1000);
        priceOracle.setPrice(TOKEN0, TOKEN1, 6000e18); // 100% deviation
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with max threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test14_LVRDetectionWithDifferentTokens() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different tokens");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test15_LVRDetectionWithSmallSwap() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle small swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test16_LVRDetectionWithLargeSwap() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle large swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test17_LVRDetectionWithNegativeAmount() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle negative amounts");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test18_LVRDetectionWithDifferentCallers() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different callers");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test19_LVRDetectionWithPriceLimit() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle price limits");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test20_LVRDetectionWithZeroForOneFalse() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with zeroForOne false");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test21_LVRDetectionWithBothPricesZero() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle both prices zero");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test22_LVRDetectionWithBothPricesMax() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle both prices max");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test23_LVRDetectionWithIdenticalPrices() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle identical prices");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test24_LVRDetectionWithJustOverThreshold() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle just over threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test25_LVRDetectionWithJustUnderThreshold() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle just under threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test26_LVRDetectionWithMultipleThresholdChanges() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with updated threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test27_LVRDetectionWithMaxAmount() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle max amount");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test28_LVRDetectionWithMinAmount() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle min amount");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test29_LVRDetectionWithZeroAmount() public {
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
            amountSpecified: 0,
            sqrtPriceLimitX96: 0
        });
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle zero amount");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test30_LVRDetectionWithDifferentFees() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different fees");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test31_LVRDetectionWithPausedContract() public {
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
        vm.expectRevert();
        poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
    }

    function test32_LVRDetectionWithUnpausedContract() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work when unpaused");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test33_LVRDetectionWithGasUsage() public {
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

    function test34_LVRDetectionWithEdgeCaseAmounts() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        SwapParams memory params1 = SwapParams({
            zeroForOne: true,
            amountSpecified: 1,
            sqrtPriceLimitX96: 0
        });
        SwapParams memory params2 = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e9,
            sqrtPriceLimitX96: 0
        });
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(address(this), testPoolKey, params1, "");
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(address(this), testPoolKey, params2, "");
        assertEq(selector1, hook.beforeSwap.selector, "Should handle 1 wei");
        assertEq(selector2, hook.beforeSwap.selector, "Should handle 1 gwei");
        assertEq(delta1, 0, "Should return zero delta");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test35_LVRDetectionWithHookData() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, hookData);
        assertEq(selector, hook.beforeSwap.selector, "Should handle hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test36_LVRDetectionWithEmptyHookData() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, hookData);
        assertEq(selector, hook.beforeSwap.selector, "Should handle empty hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test37_LVRDetectionWithMultiplePools() public {
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

    function test38_LVRDetectionWithComplexHookData() public {
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
        bytes memory hookData = abi.encode(
            true, // requestPrivate
            uint256(1000), // customParam1
            address(0x1234567890123456789012345678901234567890) // customParam2
        );
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, hookData);
        assertEq(selector, hook.beforeSwap.selector, "Should handle complex hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test39_LVRDetectionWithLargeHookData() public {
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
        bytes memory largeData = abi.encode(
            true,
            uint256(1000),
            address(0x1234567890123456789012345678901234567890),
            bytes32(0x1234567890123456789012345678901234567890123456789012345678901234)
        );
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, largeData);
        assertEq(selector, hook.beforeSwap.selector, "Should handle large hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test40_LVRDetectionWithStateChanges() public {
        assertEq(hook.lvrThreshold(), 50, "Initial threshold should be 50");
        hook.setLVRThreshold(75);
        assertEq(hook.lvrThreshold(), 75, "Threshold should be updated");
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with state changes");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test41_LVRDetectionWithCrossChainOnly() public {
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4000e18);
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with cross-chain only");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test42_LVRDetectionWithStandardOracleOnly() public {
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with standard oracle only");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test43_LVRDetectionWithBothOraclesDifferent() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 3500e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4000e18);
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with both oracles different");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test44_LVRDetectionWithBothOraclesSame() public {
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 4000e18);
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with both oracles same");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test45_LVRDetectionWithThresholdBoundary() public {
        hook.setLVRThreshold(50);
        priceOracle.setPrice(TOKEN0, TOKEN1, 3150e18); // Exactly at threshold
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work at threshold boundary");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test46_LVRDetectionWithBelowThreshold() public {
        hook.setLVRThreshold(50);
        priceOracle.setPrice(TOKEN0, TOKEN1, 3149e18); // Just below threshold
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work below threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test47_LVRDetectionWithAboveThreshold() public {
        hook.setLVRThreshold(50);
        priceOracle.setPrice(TOKEN0, TOKEN1, 3151e18); // Just above threshold
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
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work above threshold");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test48_LVRDetectionWithComprehensiveScenario() public {
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
        bytes memory hookData = abi.encode(true);
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, hookData);
        assertEq(selector, hook.beforeSwap.selector, "Should handle comprehensive scenario");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test49_LVRDetectionWithGasOptimization() public {
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
        for (uint i = 0; i < 10; i++) {
            poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        }
        uint256 gasUsed = gasStart - gasleft();
        assertTrue(gasUsed < 10000000, "Gas usage should be optimized");
    }

    function test50_LVRDetectionFinalComprehensiveTest() public {
        // Final comprehensive test
        assertEq(hook.lvrThreshold(), 50, "Initial threshold should be 50");
        hook.setLVRThreshold(100);
        assertEq(hook.lvrThreshold(), 100, "Threshold should be updated");
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 5000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 5100e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: false,
            amountSpecified: 10e18,
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        bytes memory hookData = abi.encode(
            true, // requestPrivate
            uint256(2000), // customParam1
            address(0x1234567890123456789012345678901234567890) // customParam2
        );
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            BOB, 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle final comprehensive test");
        assertEq(delta, 0, "Should return zero delta");
        
        // Verify final state
        assertEq(hook.lvrThreshold(), 100, "Final threshold should be 100");
    }
}
