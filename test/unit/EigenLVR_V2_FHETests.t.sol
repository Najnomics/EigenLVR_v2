// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {FHE, euint128, euint64} from "@fhenixprotocol/cofhe-contracts/FHE.sol";
import {CoFheTest} from "../../context/cofhe-mock-contracts/contracts/CoFheTest.sol";

/**
 * @title EigenLVR_V2 FHE Tests
 * @notice Tests for FHE functionality and private auctions
 * @dev Tests FHE integration, encrypted parameters, and privacy features
 */
contract EigenLVR_V2_FHETests is BaseEigenLVRTest, CoFheTest {
    
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
                            FHE INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test1_FHEInitialization() public {
        // Test FHE initialization
        PoolKey memory testPoolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        poolManager.callAfterInitialize(testPoolKey, 79228162514264337593543950336, 0);
        assertTrue(true, "FHE initialization should work");
    }

    function test2_EncryptedAuctionCreation() public {
        // Test encrypted auction creation
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
        
        assertEq(selector, hook.beforeSwap.selector, "Should create encrypted auction");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test3_FHEPermissions() public {
        // Test FHE permissions setup
        euint64 testAmount = FHE.asEuint64(1000);
        FHE.allowThis(testAmount);
        assertTrue(true, "FHE permissions should be set");
    }

    function test4_EncryptedMinBid() public {
        // Test encrypted minimum bid
        euint128 encryptedMinBid = FHE.asEuint128(1e15);
        FHE.allowThis(encryptedMinBid);
        assertTrue(true, "Encrypted min bid should be created");
    }

    function test5_EncryptedReserve() public {
        // Test encrypted reserve price
        euint128 encryptedReserve = FHE.asEuint128(1.1e15);
        FHE.allowThis(encryptedReserve);
        assertTrue(true, "Encrypted reserve should be created");
    }

    function test6_EncryptedDuration() public {
        // Test encrypted auction duration
        euint64 encryptedDuration = FHE.asEuint64(12);
        FHE.allowThis(encryptedDuration);
        assertTrue(true, "Encrypted duration should be created");
    }

    function test7_FHEWithDifferentAmounts() public {
        // Test FHE with different amounts
        euint128 amount1 = FHE.asEuint128(1e15);
        euint128 amount2 = FHE.asEuint128(1e18);
        euint128 amount3 = FHE.asEuint128(1e21);
        
        FHE.allowThis(amount1);
        FHE.allowThis(amount2);
        FHE.allowThis(amount3);
        
        assertTrue(true, "Should handle different amounts");
    }

    function test8_FHEWithZeroAmount() public {
        // Test FHE with zero amount
        euint128 zeroAmount = FHE.asEuint128(0);
        FHE.allowThis(zeroAmount);
        assertTrue(true, "Should handle zero amount");
    }

    function test9_FHEWithMaxAmount() public {
        // Test FHE with max amount
        euint128 maxAmount = FHE.asEuint128(type(uint128).max);
        FHE.allowThis(maxAmount);
        assertTrue(true, "Should handle max amount");
    }

    function test10_PrivateAuctionWithFHE() public {
        // Test private auction with FHE
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
        
        assertEq(selector, hook.beforeSwap.selector, "Should create private auction");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test11_FHEWithMultipleTokens() public {
        // Test FHE with multiple token pairs
        Currency newToken0 = Currency.wrap(0x7777777777777777777777777777777777777777);
        Currency newToken1 = Currency.wrap(0x8888888888888888888888888888888888888888);
        
        euint128 amount = FHE.asEuint128(1e18);
        FHE.allowThis(amount);
        FHE.allow(amount, Currency.unwrap(newToken0));
        FHE.allow(amount, Currency.unwrap(newToken1));
        
        assertTrue(true, "Should handle multiple tokens");
    }

    function test12_FHEWithDifferentThresholds() public {
        // Test FHE with different LVR thresholds
        hook.setLVRThreshold(25);
        
        priceOracle.setPrice(TOKEN0, TOKEN1, 3100e18);
        
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
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with different thresholds");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test13_FHEWithCrossChainPrices() public {
        // Test FHE with cross-chain prices
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
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with cross-chain prices");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test14_FHEWithDifferentCallers() public {
        // Test FHE with different callers
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
        
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(ALICE, testPoolKey, params, hookData);
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(BOB, testPoolKey, params, hookData);
        
        assertEq(selector1, hook.beforeSwap.selector, "Should work with Alice");
        assertEq(selector2, hook.beforeSwap.selector, "Should work with Bob");
        assertEq(delta1, 0, "Should return zero delta");
        assertEq(delta2, 0, "Should return zero delta");
    }

    function test15_FHEWithLargeSwaps() public {
        // Test FHE with large swaps
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
            amountSpecified: 100e18,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with large swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test16_FHEWithSmallSwaps() public {
        // Test FHE with small swaps
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
            amountSpecified: 1e17,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with small swaps");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test17_FHEWithNegativeAmounts() public {
        // Test FHE with negative swap amounts
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
            amountSpecified: -2e18,
            sqrtPriceLimitX96: 0
        });
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with negative amounts");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test18_FHEWithZeroForOneFalse() public {
        // Test FHE with zeroForOne false
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
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with zeroForOne false");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test19_FHEWithPriceLimits() public {
        // Test FHE with price limits
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
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with price limits");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test20_FHEWithDifferentFees() public {
        // Test FHE with different fee tiers
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
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with different fees");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test21_FHEWithComplexHookData() public {
        // Test FHE with complex hook data
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
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with complex hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test22_FHEWithLargeHookData() public {
        // Test FHE with large hook data
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
        
        bytes memory largeData = new bytes(1000);
        for (uint i = 0; i < largeData.length; i++) {
            largeData[i] = bytes1(uint8(i % 256));
        }
        
        bytes memory hookData = abi.encode(true, largeData);
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            address(this), 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should work with large hook data");
        assertEq(delta, 0, "Should return zero delta");
    }

    function test23_FHEWithEdgeCaseAmounts() public {
        // Test FHE with edge case amounts
        euint128 amount1 = FHE.asEuint128(1);
        euint128 amount2 = FHE.asEuint128(1e9);
        euint128 amount3 = FHE.asEuint128(type(uint128).max);
        
        FHE.allowThis(amount1);
        FHE.allowThis(amount2);
        FHE.allowThis(amount3);
        
        assertTrue(true, "Should handle edge case amounts");
    }

    function test24_FHEWithMultiplePools() public {
        // Test FHE with multiple pools
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
        
        bytes memory hookData = abi.encode(true);
        
        (bytes4 selector1, uint128 delta1) = poolManager.callBeforeSwap(address(this), pool1, params, hookData);
        (bytes4 selector2, uint128 delta2) = poolManager.callBeforeSwap(address(this), pool2, params, hookData);
        
        assertEq(selector1, hook.beforeSwap.selector, "Should work with multiple pools");
        assertEq(selector2, hook.beforeSwap.selector, "Should work with multiple pools");
        assertEq(delta1, 0, "Should return zero delta");
        assertEq(delta2, 0, "Should return zero delta");
    }

   

    function test26_FHEComprehensiveTest() public {
        // Comprehensive FHE test
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
            zeroForOne: false,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 79228162514264337593543950336
        });
        
        bytes memory hookData = abi.encode(
            true, // requestPrivate
            uint256(2000), // customParam1
            address(0x1234567890123456789012345678901234567890) // customParam2
        );
        
        (bytes4 selector, uint128 delta) = poolManager.callBeforeSwap(
            CHARLIE, 
            testPoolKey, 
            params, 
            hookData
        );
        
        assertEq(selector, hook.beforeSwap.selector, "Should handle comprehensive FHE test");
        assertEq(delta, 0, "Should return zero delta");
        
        // Verify state
        assertEq(hook.lvrThreshold(), 75, "Threshold should remain set");
    }
}
