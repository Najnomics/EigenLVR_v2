// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

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
}
