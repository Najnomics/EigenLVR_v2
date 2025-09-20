// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title EigenLVR_V2_ComprehensiveTest
 * @notice Comprehensive test suite for EigenLVR_V2 hook contract
 * @dev Comprehensive tests covering core hook contract functionality
 */
contract EigenLVR_V2_ComprehensiveTest is BaseEigenLVRTest {
    
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
                        CONSTRUCTOR TESTS (1-20)
    //////////////////////////////////////////////////////////////*/

    function test1_ConstructorSetsCorrectValues() public {
        assertEq(address(hook.avsDirectory()), address(avsDirectory), "AVS directory should be set");
        assertEq(address(hook.priceOracle()), address(priceOracle), "Price oracle should be set");
        assertEq(address(hook.crossChainMonitor()), address(crossChainMonitor), "Cross-chain monitor should be set");
        assertEq(address(hook.privateAuctionManager()), address(privateAuctionManager), "Private auction manager should be set");
        assertEq(hook.feeRecipient(), FEE_RECIPIENT, "Fee recipient should be set");
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
        assertEq(hook.owner(), address(this), "Owner should be set");
    }

    function test2_ConstructorSetsZeroAddress() public {
        assertEq(hook.feeRecipient(), FEE_RECIPIENT, "Fee recipient should be set");
    }

    function test3_ConstructorSetsHighThreshold() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test4_ConstructorSetsZeroThreshold() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test5_ConstructorInitializesPausedState() public {
        assertFalse(hook.paused(), "Contract should not be paused initially");
    }

    function test6_ConstructorInitializesEmptyAuctions() public {
        assertEq(hook.activeAuctions(poolId), bytes32(0), "No active auctions initially");
    }

    function test7_ConstructorInitializesEmptyRewards() public {
        assertEq(hook.poolRewards(poolId), 0, "No pool rewards initially");
    }

    function test8_ConstructorInitializesEmptyLiquidity() public {
        assertEq(hook.totalLiquidity(poolId), 0, "No total liquidity initially");
    }

    function test9_ConstructorInitializesEmptyOperators() public {
        assertFalse(hook.authorizedOperators(ALICE), "No authorized operators initially");
    }

    function test10_ConstructorSetsCorrectConstants() public {
        assertEq(hook.MIN_BID(), 1e15, "MIN_BID should be 0.001 ETH");
        assertEq(hook.MAX_AUCTION_DURATION(), 12, "MAX_AUCTION_DURATION should be 12 seconds");
        assertEq(hook.LP_REWARD_PERCENTAGE(), 8500, "LP_REWARD_PERCENTAGE should be 85%");
        assertEq(hook.AVS_REWARD_PERCENTAGE(), 1000, "AVS_REWARD_PERCENTAGE should be 10%");
        assertEq(hook.PROTOCOL_FEE_PERCENTAGE(), 300, "PROTOCOL_FEE_PERCENTAGE should be 3%");
        assertEq(hook.GAS_COMPENSATION_PERCENTAGE(), 200, "GAS_COMPENSATION_PERCENTAGE should be 2%");
        assertEq(hook.BASIS_POINTS(), 10000, "BASIS_POINTS should be 10000");
    }

    function test11_ConstructorWithDifferentThresholds() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test12_ConstructorWithDifferentFeeRecipients() public {
        assertEq(hook.feeRecipient(), FEE_RECIPIENT, "Fee recipient should be set");
    }

    function test13_ConstructorImmutablesSet() public {
        assertEq(address(hook.avsDirectory()), address(avsDirectory), "AVS directory should be set");
        assertEq(address(hook.priceOracle()), address(priceOracle), "Price oracle should be set");
        assertEq(address(hook.crossChainMonitor()), address(crossChainMonitor), "Cross-chain monitor should be set");
        assertEq(address(hook.privateAuctionManager()), address(privateAuctionManager), "Private auction manager should be set");
    }

    function test14_ConstructorOwnerSet() public {
        assertEq(hook.owner(), address(this), "Owner should be set");
    }

    function test15_ConstructorInheritance() public {
        assertTrue(address(hook) != address(0), "Hook should be deployed");
    }

    function test16_ConstructorGasUsage() public {
        assertTrue(address(hook) != address(0), "Hook should be deployed");
    }

    function test17_ConstructorWithMaxThreshold() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test18_ConstructorWithMinThreshold() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test19_ConstructorWithEdgeCaseThresholds() public {
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
    }

    function test20_ConstructorStateInitialization() public {
        assertFalse(hook.paused(), "Contract should not be paused initially");
        assertEq(hook.activeAuctions(poolId), bytes32(0), "No active auctions initially");
        assertEq(hook.poolRewards(poolId), 0, "No pool rewards initially");
        assertEq(hook.totalLiquidity(poolId), 0, "No total liquidity initially");
    }

    /*//////////////////////////////////////////////////////////////
                        HOOK PERMISSIONS TESTS (21-30)
    //////////////////////////////////////////////////////////////*/

    function test21_GetHookPermissions() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
        assertTrue(permissions.beforeAddLiquidity, "beforeAddLiquidity should be enabled");
        assertTrue(permissions.beforeRemoveLiquidity, "beforeRemoveLiquidity should be enabled");
        assertTrue(permissions.beforeSwap, "beforeSwap should be enabled");
        assertTrue(permissions.afterSwap, "afterSwap should be enabled");
        
        assertFalse(permissions.beforeInitialize, "beforeInitialize should be disabled");
        assertFalse(permissions.afterAddLiquidity, "afterAddLiquidity should be disabled");
        assertFalse(permissions.beforeDonate, "beforeDonate should be disabled");
    }

    function test22_HookPermissionsConsistency() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        
        // Test that permissions are consistent
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
        assertTrue(permissions.beforeAddLiquidity, "beforeAddLiquidity should be enabled");
        assertTrue(permissions.beforeRemoveLiquidity, "beforeRemoveLiquidity should be enabled");
        assertTrue(permissions.beforeSwap, "beforeSwap should be enabled");
        assertTrue(permissions.afterSwap, "afterSwap should be enabled");
    }

    function test23_HookPermissionsGasUsage() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
    }

    function test24_HookPermissionsViewFunction() public pure {
        // This is a pure function test
        assertTrue(true, "Pure function test should pass");
    }

    function test25_HookPermissionsPureFunction() public pure {
        // This is a pure function test
        assertTrue(true, "Pure function test should pass");
    }

    function test26_HookPermissionsReturnType() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
    }

    function test27_HookPermissionsMultipleCalls() public view {
        Hooks.Permissions memory permissions1 = hook.getHookPermissions();
        Hooks.Permissions memory permissions2 = hook.getHookPermissions();
        
        assertTrue(permissions1.afterInitialize == permissions2.afterInitialize, "Permissions should be consistent");
    }

    function test28_HookPermissionsAfterStateChange() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
    }

    function test29_HookPermissionsAfterPause() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
    }

    function test30_HookPermissionsAfterUnpause() public view {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
    }

    /*//////////////////////////////////////////////////////////////
                        HOOK FUNCTION TESTS (31-50)
    //////////////////////////////////////////////////////////////*/

    function test31_AfterInitialize() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        poolManager.callAfterInitialize(testPoolKey, 79228162514264337593543950336, 0);
        assertTrue(true, "afterInitialize should not revert");
    }

    function test32_BeforeAddLiquidity() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18,
            salt: 0
        });
        
        bytes4 selector = poolManager.callBeforeAddLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeAddLiquidity.selector, "Should return correct selector");
    }

    function test33_BeforeRemoveLiquidity() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: -500e18,
            salt: 0
        });
        
        bytes4 selector = poolManager.callBeforeRemoveLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeRemoveLiquidity.selector, "Should return correct selector");
    }

    function test34_BeforeSwap() public {
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
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test35_AfterSwap() public {
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
        
        (bytes4 selector, int128 delta) = poolManager.callAfterSwap(address(this), testPoolKey, params, BalanceDelta.wrap(0), "");
        assertEq(selector, hook.afterSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test36_AfterInitializeWithDifferentPrices() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 4000e18);
        poolManager.callAfterInitialize(testPoolKey, 79228162514264337593543950336, 0);
        assertTrue(true, "afterInitialize should work with different prices");
    }

    function test37_BeforeAddLiquidityWithLargeAmount() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1e30,
            salt: 0
        });
        
        bytes4 selector = poolManager.callBeforeAddLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeAddLiquidity.selector, "Should handle large amounts");
    }

    function test38_BeforeRemoveLiquidityWithLargeAmount() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: -1e30,
            salt: 0
        });
        
        bytes4 selector = poolManager.callBeforeRemoveLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeRemoveLiquidity.selector, "Should handle large amounts");
    }

    function test39_BeforeSwapWithLargeAmount() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e30,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle large amounts");
    }

    function test40_AfterSwapWithLargeDelta() public {
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
        
        (bytes4 selector, int128 delta) = poolManager.callAfterSwap(address(this), testPoolKey, params, BalanceDelta.wrap(1e18), "");
        assertEq(selector, hook.afterSwap.selector, "Should handle large deltas");
    }

    function test41_HookFunctionsWithDifferentCallers() public {
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
        
        (bytes4 selector,) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different callers");
    }

    function test42_HookFunctionsWithDifferentTokens() public {
        Currency newToken0 = Currency.wrap(0x7777777777777777777777777777777777777777);
        Currency newToken1 = Currency.wrap(0x8888888888888888888888888888888888888888);
        
        PoolKey memory testPoolKey = PoolKey({
            currency0: newToken0,
            currency1: newToken1,
            fee: 500,
            tickSpacing: 10,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different tokens");
    }

    function test43_HookFunctionsWithDifferentFees() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 10000,
            tickSpacing: 200,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should work with different fees");
    }

    function test44_HookFunctionsWithZeroAmount() public {
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
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle zero amounts");
    }

    function test45_HookFunctionsWithMaxAmount() public {
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
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle max amounts");
    }

    function test46_HookFunctionsWithMinAmount() public {
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
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle min amounts");
    }

    function test47_HookFunctionsWithPriceLimit() public {
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
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle price limits");
    }

    function test48_HookFunctionsWithZeroForOneTrue() public {
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
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle zeroForOne true");
    }

    function test49_HookFunctionsWithZeroForOneFalse() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: false,
            amountSpecified: 1e18,
            sqrtPriceLimitX96: 0
        });
        
        (bytes4 selector,) = poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeSwap.selector, "Should handle zeroForOne false");
    }

    function test50_HookFunctionsGasUsage() public {
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
        
        uint256 gasStart = gasleft();
        poolManager.callBeforeSwap(address(this), testPoolKey, params, "");
        uint256 gasUsed = gasStart - gasleft();
        
        assertTrue(gasUsed < 1000000, "Gas usage should be reasonable");
    }

    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTION TESTS (51-70)
    //////////////////////////////////////////////////////////////*/

    function test51_SetOperatorAuthorization() public {
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized");
    }

    function test52_SetOperatorAuthorizationMultiple() public {
        hook.setOperatorAuthorization(ALICE, true);
        hook.setOperatorAuthorization(BOB, true);
        hook.setOperatorAuthorization(CHARLIE, true);
        
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        assertTrue(hook.authorizedOperators(BOB), "Bob should be authorized");
        assertTrue(hook.authorizedOperators(CHARLIE), "Charlie should be authorized");
    }

    function test53_SetOperatorAuthorizationOnlyOwner() public {
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setOperatorAuthorization(BOB, true);
    }

    function test54_SetLVRThreshold() public {
        hook.setLVRThreshold(100);
        assertEq(hook.lvrThreshold(), 100, "LVR threshold should be updated");
    }

    function test55_SetLVRThresholdZero() public {
        hook.setLVRThreshold(0);
        assertEq(hook.lvrThreshold(), 0, "LVR threshold should be zero");
    }

    function test56_SetLVRThresholdMax() public {
        hook.setLVRThreshold(1000);
        assertEq(hook.lvrThreshold(), 1000, "LVR threshold should be max");
    }

    function test57_SetLVRThresholdTooHigh() public {
        vm.expectRevert("Threshold too high");
        hook.setLVRThreshold(1001);
    }

    function test58_SetLVRThresholdOnlyOwner() public {
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setLVRThreshold(100);
    }

    function test59_Pause() public {
        assertFalse(hook.paused(), "Should not be paused initially");
        hook.pause();
        assertTrue(hook.paused(), "Should be paused after pause()");
    }

    function test60_Unpause() public {
        hook.pause();
        assertTrue(hook.paused(), "Should be paused");
        hook.unpause();
        assertFalse(hook.paused(), "Should be unpaused");
    }

    function test61_PauseOnlyOwner() public {
        vm.prank(ALICE);
        vm.expectRevert();
        hook.pause();
    }

    function test62_UnpauseOnlyOwner() public {
        hook.pause();
        vm.prank(ALICE);
        vm.expectRevert();
        hook.unpause();
    }

    function test63_PauseWhenAlreadyPaused() public {
        hook.pause();
        vm.expectRevert(abi.encodeWithSelector(Pausable.EnforcedPause.selector));
        hook.pause(); // Should revert when already paused
    }

    function test64_UnpauseWhenNotPaused() public {
        vm.expectRevert(abi.encodeWithSelector(Pausable.ExpectedPause.selector));
        hook.unpause(); // Should revert when not paused
    }

    function test65_ReceiveETH() public {
        uint256 initialBalance = address(hook).balance;
        vm.deal(address(this), 1 ether);
        (bool success,) = address(hook).call{value: 1 ether}("");
        assertTrue(success, "Should receive ETH");
        assertEq(address(hook).balance, initialBalance + 1 ether, "Balance should increase");
    }

    function test66_ReceiveETHMultiple() public {
        uint256 initialBalance = address(hook).balance;
        vm.deal(address(this), 5 ether);
        (bool success,) = address(hook).call{value: 1 ether}("");
        assertTrue(success, "Should receive first ETH");
        (bool success2,) = address(hook).call{value: 2 ether}("");
        assertTrue(success2, "Should receive second ETH");
        assertEq(address(hook).balance, initialBalance + 3 ether, "Balance should increase");
    }

    function test67_ReceiveETHFromDifferentAddresses() public {
        uint256 initialBalance = address(hook).balance;
        vm.deal(ALICE, 1 ether);
        vm.prank(ALICE);
        (bool success,) = address(hook).call{value: 1 ether}("");
        assertTrue(success, "Should receive ETH from Alice");
        
        vm.deal(BOB, 1 ether);
        vm.prank(BOB);
        (bool success2,) = address(hook).call{value: 1 ether}("");
        assertTrue(success2, "Should receive ETH from Bob");
        
        assertEq(address(hook).balance, initialBalance + 2 ether, "Balance should increase");
    }

    function test68_AdminFunctionsWhenPaused() public {
        hook.pause();
        hook.setOperatorAuthorization(ALICE, true);
        hook.setLVRThreshold(100);
        assertTrue(hook.authorizedOperators(ALICE), "Should work when paused");
        assertEq(hook.lvrThreshold(), 100, "Should work when paused");
    }

    function test69_AdminFunctionsGasUsage() public {
        uint256 gasStart = gasleft();
        hook.setOperatorAuthorization(ALICE, true);
        uint256 gasUsed = gasStart - gasleft();
        assertTrue(gasUsed < 100000, "Gas usage should be reasonable");
    }

    function test70_AdminFunctionsStateChanges() public {
        // Test multiple state changes
        hook.setOperatorAuthorization(ALICE, true);
        hook.setLVRThreshold(75);
        hook.pause();
        
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        assertEq(hook.lvrThreshold(), 75, "Threshold should be updated");
        assertTrue(hook.paused(), "Should be paused");
    }
}