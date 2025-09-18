// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "./utils/BaseEigenLVRTest.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {FHE, InEuint128, InEuint64} from "@fhenixprotocol/cofhe-contracts/FHE.sol";
import {CoFheTest} from "../context/cofhe-mock-contracts/contracts/CoFheTest.sol";

/**
 * @title EigenLVR_V2 Main Tests
 * @notice Main test suite for EigenLVR_V2 functionality
 * @dev Comprehensive tests including FHE functionality
 */
contract EigenLVR_V2Test is BaseEigenLVRTest, CoFheTest {
    
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
                            HOOK PERMISSIONS TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testHookPermissions() public view {
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

    /*//////////////////////////////////////////////////////////////
                            HOOK FUNCTION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testAfterInitialize() public {
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Test afterInitialize hook through PoolManager
        poolManager.callAfterInitialize(testPoolKey, 79228162514264337593543950336, 0);
        
        // Verify hook was called (no revert means success)
        assertTrue(true, "afterInitialize should not revert");
    }

    function testBeforeAddLiquidity() public {
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

    function testBeforeRemoveLiquidity() public {
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

    function testBeforeSwap() public {
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
        
        // Test beforeSwap hook through PoolManager
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            ""
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }

    function testAfterSwap() public {
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
        
        // Test afterSwap hook through PoolManager
        (bytes4 selector, int128 delta) = poolManager.callAfterSwap(
            address(this), 
            testPoolKey, 
            params, 
            BalanceDelta.wrap(0), 
            ""
        );
        
        assertEq(selector, hook.afterSwap.selector, "Should return correct selector");
        assertEq(delta, 0, "Should return zero delta");
    }
    
    /*//////////////////////////////////////////////////////////////
                            BASIC FUNCTIONALITY TESTS
    //////////////////////////////////////////////////////////////*/

    function testInitialState() public view {
        assertEq(address(hook.avsDirectory()), address(avsDirectory), "AVS directory should be set");
        assertEq(address(hook.priceOracle()), address(priceOracle), "Price oracle should be set");
        assertEq(address(hook.crossChainMonitor()), address(crossChainMonitor), "Cross-chain monitor should be set");
        assertEq(address(hook.privateAuctionManager()), address(privateAuctionManager), "Private auction manager should be set");
        assertEq(hook.feeRecipient(), FEE_RECIPIENT, "Fee recipient should be set");
        assertEq(hook.lvrThreshold(), 50, "LVR threshold should be set");
        assertEq(hook.owner(), address(this), "Owner should be set");
    }

    function testConstants() public view {
        assertEq(hook.MIN_BID(), 1e15, "MIN_BID should be 0.001 ETH");
        assertEq(hook.MAX_AUCTION_DURATION(), 12, "MAX_AUCTION_DURATION should be 12 seconds");
        assertEq(hook.LP_REWARD_PERCENTAGE(), 8500, "LP_REWARD_PERCENTAGE should be 85%");
        assertEq(hook.AVS_REWARD_PERCENTAGE(), 1000, "AVS_REWARD_PERCENTAGE should be 10%");
        assertEq(hook.PROTOCOL_FEE_PERCENTAGE(), 300, "PROTOCOL_FEE_PERCENTAGE should be 3%");
        assertEq(hook.GAS_COMPENSATION_PERCENTAGE(), 200, "GAS_COMPENSATION_PERCENTAGE should be 2%");
        assertEq(hook.BASIS_POINTS(), 10000, "BASIS_POINTS should be 10000");
    }

    function testPauseUnpause() public {
        // Test pause
        hook.pause();
        assertTrue(hook.paused(), "Contract should be paused");
        
        // Test unpause
        hook.unpause();
        assertFalse(hook.paused(), "Contract should be unpaused");
    }
    
    function testOperatorAuthorization() public {
        // Test setting operator authorization
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized");
    }
    
    function testLVRThresholdUpdate() public {
        // Test setting LVR threshold
        hook.setLVRThreshold(100);
        assertEq(hook.lvrThreshold(), 100, "LVR threshold should be updated");
        
        // Test setting invalid threshold
        vm.expectRevert("Threshold too high");
        hook.setLVRThreshold(1001);
    }

    function testReceiveETH() public {
        // Test receiving ETH
        uint256 initialBalance = address(hook).balance;
        vm.deal(address(this), 1 ether);
        (bool success,) = address(hook).call{value: 1 ether}("");
        assertTrue(success, "Should receive ETH");
        assertEq(address(hook).balance, initialBalance + 1 ether, "Balance should increase");
    }
    
    /*//////////////////////////////////////////////////////////////
                            FHE FUNCTIONALITY TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testFHEIntegration() public {
        // Test FHE integration with private auctions
        // This is a placeholder for FHE-specific tests
        // In a real implementation, you would test encrypted operations here
        
        // For now, just test that the hook can be deployed with FHE dependencies
        assertTrue(address(hook) != address(0), "Hook should be deployed");
        assertTrue(address(hook.privateAuctionManager()) != address(0), "Private auction manager should be set");
    }

    function testPrivateAuctionCreation() public {
        // Test creating a private auction
        // This would involve FHE operations in a real implementation
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
        
        // Test with private auction request
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
}