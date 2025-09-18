// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

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
}
