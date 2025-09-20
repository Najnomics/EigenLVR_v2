// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

/**
 * @title EigenLVR_V2 Integration Tests
 * @notice Tests for integration scenarios and edge cases
 * @dev Tests complex workflows, edge cases, and integration scenarios
 */
contract EigenLVR_V2_IntegrationTests is BaseEigenLVRTest {
    
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
                            INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test1_FullWorkflowIntegration() public {
        // Test full workflow integration
        hook.setLVRThreshold(50);
        
        // Add liquidity
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        ModifyLiquidityParams memory liquidityParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18,
            salt: 0
        });
        
        bytes4 selector1 = poolManager.callBeforeAddLiquidity(address(this), testPoolKey, liquidityParams, "");
        assertEq(selector1, hook.beforeAddLiquidity.selector, "Should handle liquidity addition");
        
        // Perform swap with LVR
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        
        SwapParams memory swapParams = SwapParams({
            zeroForOne: true,
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector2, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, swapParams, "");
        assertEq(selector2, hook.beforeSwap.selector, "Should handle swap");
        assertEq(delta, 0, "Should return zero delta");
        
        // After swap processing
        (bytes4 selector3, int128 delta2) = poolManager.callAfterSwap(
            address(this), 
            testPoolKey, 
            swapParams, 
            BalanceDelta.wrap(0), 
            ""
        );
        assertEq(selector3, hook.afterSwap.selector, "Should handle after swap");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test2_MultiplePoolIntegration() public {
        // Test multiple pool integration
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

    function test3_CrossChainIntegration() public {
        // Test cross-chain integration
        hook.setLVRThreshold(75);
        
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
        assertEq(selector, hook.beforeSwap.selector, "Should handle cross-chain integration");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test4_PrivateAuctionIntegration() public {
        // Test private auction integration
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
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle private auction integration");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test5_LiquidityManagementIntegration() public {
        // Test liquidity management integration
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Add liquidity
        ModifyLiquidityParams memory addParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18,
            salt: 0
        });
        
        bytes4 selector1 = poolManager.callBeforeAddLiquidity(address(this), testPoolKey, addParams, "");
        assertEq(selector1, hook.beforeAddLiquidity.selector, "Should add liquidity");
        
        // Remove liquidity
        ModifyLiquidityParams memory removeParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: -500e18,
            salt: 0
        });
        
        bytes4 selector2 = poolManager.callBeforeRemoveLiquidity(address(this), testPoolKey, removeParams, "");
        assertEq(selector2, hook.beforeRemoveLiquidity.selector, "Should remove liquidity");
    }

    function test6_ThresholdManagementIntegration() public {
        // Test threshold management integration
        assertEq(hook.lvrThreshold(), 50, "Initial threshold should be 50");
        
        hook.setLVRThreshold(25);
        assertEq(hook.lvrThreshold(), 25, "Threshold should be updated to 25");
        
        hook.setLVRThreshold(100);
        assertEq(hook.lvrThreshold(), 100, "Threshold should be updated to 100");
        
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

    function test7_OperatorManagementIntegration() public {
        // Test operator management integration
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized initially");
        
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        
        hook.setOperatorAuthorization(BOB, true);
        assertTrue(hook.authorizedOperators(BOB), "Bob should be authorized");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized");
        assertTrue(hook.authorizedOperators(BOB), "Bob should still be authorized");
    }

    function test8_PauseUnpauseIntegration() public {
        // Test pause/unpause integration
        assertFalse(hook.paused(), "Should not be paused initially");
        
        hook.pause();
        assertTrue(hook.paused(), "Should be paused");
        
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
        
        hook.unpause();
        assertFalse(hook.paused(), "Should be unpaused");
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work after unpause");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test9_StateConsistencyIntegration() public {
        // Test state consistency integration
        hook.setLVRThreshold(75);
        hook.setOperatorAuthorization(ALICE, true);
        
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
            amountSpecified: 2e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should maintain state consistency");
        assertEq(delta, 0, "Should return zero delta");
        
        // Verify state remains consistent
        assertEq(hook.lvrThreshold(), 75, "Threshold should remain consistent");
        assertTrue(hook.authorizedOperators(ALICE), "Alice should remain authorized");
    }

    function test10_GasOptimizationIntegration() public {
        // Test gas optimization integration
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

    function test11_EdgeCaseIntegration() public {
        // Test edge case integration
        priceOracle.setPrice(TOKEN0, TOKEN1, 0);
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
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle edge cases");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test12_ComprehensiveIntegration() public {
        // Test comprehensive integration
        hook.setLVRThreshold(100);
        hook.setOperatorAuthorization(ALICE, true);
        hook.setOperatorAuthorization(BOB, true);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 5000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 5100e18);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Add liquidity
        ModifyLiquidityParams memory liquidityParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 2000e18,
            salt: 0
        });
        
        bytes4 selector1 = poolManager.callBeforeAddLiquidity(ALICE, testPoolKey, liquidityParams, "");
        assertEq(selector1, hook.beforeAddLiquidity.selector, "Should add liquidity");
        
        // Perform swap
        SwapParams memory swapParams = SwapParams({
            zeroForOne: false,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        bytes memory hookData = abi.encode(true); // Request private auction
        
        (bytes4 selector2, uint128 delta) = poolManager.callBeforeSwap(
            BOB, 
            testPoolKey, 
            swapParams, 
            hookData
        );
        assertEq(selector2, hook.beforeSwap.selector, "Should perform swap");
        assertEq(delta, 0, "Should return zero delta");
        
        // After swap processing
        (bytes4 selector3, int128 delta2) = poolManager.callAfterSwap(
            BOB, 
            testPoolKey, 
            swapParams, 
            BalanceDelta.wrap(1e18), 
            hookData
        );
        assertEq(selector3, hook.afterSwap.selector, "Should process after swap");
        assertEq(delta2, 0, "Should return zero delta");
        
        // Remove some liquidity
        ModifyLiquidityParams memory removeParams = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: -1000e18,
            salt: 0
        });
        
        bytes4 selector4 = poolManager.callBeforeRemoveLiquidity(ALICE, testPoolKey, removeParams, "");
        assertEq(selector4, hook.beforeRemoveLiquidity.selector, "Should remove liquidity");
        
        // Verify final state
        assertEq(hook.lvrThreshold(), 100, "Final threshold should be 100");
        assertTrue(hook.authorizedOperators(ALICE), "Alice should remain authorized");
        assertTrue(hook.authorizedOperators(BOB), "Bob should remain authorized");
    }
}
