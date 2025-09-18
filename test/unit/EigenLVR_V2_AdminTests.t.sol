// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseEigenLVRTest} from "../utils/BaseEigenLVRTest.sol";

/**
 * @title EigenLVR_V2 Admin Tests
 * @notice Tests for admin functionality
 * @dev Tests owner-only functions and administrative controls
 */
contract EigenLVR_V2_AdminTests is BaseEigenLVRTest {
    
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
                            ADMIN FUNCTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testOperatorAuthorization() public {
        // Test setting operator authorization
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized");
        
        hook.setOperatorAuthorization(BOB, true);
        assertTrue(hook.authorizedOperators(BOB), "Bob should be authorized");
    }

    function testLVRThresholdUpdate() public {
        // Test setting LVR threshold
        hook.setLVRThreshold(100);
        assertEq(hook.lvrThreshold(), 100, "LVR threshold should be updated");
        
        hook.setLVRThreshold(500);
        assertEq(hook.lvrThreshold(), 500, "LVR threshold should be updated again");
        
        // Test setting invalid threshold
        vm.expectRevert("Threshold too high");
        hook.setLVRThreshold(1001);
    }

    function testPauseUnpause() public {
        // Test pause
        hook.pause();
        assertTrue(hook.paused(), "Contract should be paused");
        
        // Test unpause
        hook.unpause();
        assertFalse(hook.paused(), "Contract should be unpaused");
    }

    function testOnlyOwnerFunctions() public {
        // Test that only owner can call admin functions
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setOperatorAuthorization(BOB, true);

        vm.prank(ALICE);
        vm.expectRevert();
        hook.setLVRThreshold(100);
        
        vm.prank(ALICE);
        vm.expectRevert();
        hook.pause();
        
        vm.prank(ALICE);
        vm.expectRevert();
        hook.unpause();
    }

    function testOwnerTransfer() public {
        // Test owner transfer
        address newOwner = ALICE;
        hook.transferOwnership(newOwner);
        assertEq(hook.owner(), newOwner, "Owner should be transferred");
        
        // Test that old owner can't call admin functions
        vm.expectRevert();
        hook.setOperatorAuthorization(BOB, true);
    }

    function testReceiveETH() public {
        // Test receiving ETH
        uint256 initialBalance = address(hook).balance;
        vm.deal(address(this), 1 ether);
        (bool success,) = address(hook).call{value: 1 ether}("");
        assertTrue(success, "Should receive ETH");
        assertEq(address(hook).balance, initialBalance + 1 ether, "Balance should increase");
    }
}