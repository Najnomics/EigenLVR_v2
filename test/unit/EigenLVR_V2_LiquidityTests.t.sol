// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

/**
 * @title EigenLVR_V2 Liquidity Tests
 * @notice Tests for liquidity tracking functionality
 * @dev Tests liquidity addition, removal, and tracking
 */
contract EigenLVR_V2_LiquidityTests is BaseEigenLVRTest {
    
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
                            LIQUIDITY FUNCTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testAddLiquidity() public {
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
        
        // Test beforeAddLiquidity hook through PoolManager
        bytes4 selector = poolManager.callBeforeAddLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeAddLiquidity.selector, "Should return correct selector");
    }

    function testRemoveLiquidity() public {
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
        
        // Test beforeRemoveLiquidity hook through PoolManager
        bytes4 selector = poolManager.callBeforeRemoveLiquidity(address(this), testPoolKey, params, "");
        assertEq(selector, hook.beforeRemoveLiquidity.selector, "Should return correct selector");
    }

    function testLiquidityTracking() public {
        // Test initial liquidity state
        assertEq(hook.totalLiquidity(poolId), 0, "Initial total liquidity should be 0");
        assertEq(hook.lpLiquidity(poolId, ALICE), 0, "Initial LP liquidity should be 0");
        assertEq(hook.lpLiquidity(poolId, BOB), 0, "Initial LP liquidity should be 0");
    }

    function testRewardDistribution() public view {
        // Test reward distribution constants
        assertEq(hook.LP_REWARD_PERCENTAGE(), 8500, "LP_REWARD_PERCENTAGE should be 85%");
        assertEq(hook.AVS_REWARD_PERCENTAGE(), 1000, "AVS_REWARD_PERCENTAGE should be 10%");
        assertEq(hook.PROTOCOL_FEE_PERCENTAGE(), 300, "PROTOCOL_FEE_PERCENTAGE should be 3%");
        assertEq(hook.GAS_COMPENSATION_PERCENTAGE(), 200, "GAS_COMPENSATION_PERCENTAGE should be 2%");
        assertEq(hook.BASIS_POINTS(), 10000, "BASIS_POINTS should be 10000");
    }

    function testRewardDistributionPercentages() public view {
        // Test that percentages add up to 100%
        uint256 total = hook.LP_REWARD_PERCENTAGE() + 
                       hook.AVS_REWARD_PERCENTAGE() + 
                       hook.PROTOCOL_FEE_PERCENTAGE() + 
                       hook.GAS_COMPENSATION_PERCENTAGE();
        
        assertEq(total, hook.BASIS_POINTS(), "Total percentages should equal BASIS_POINTS");
    }
}
