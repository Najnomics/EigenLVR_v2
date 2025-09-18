// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {EigenLVRTaskHook} from "../src/l2-contracts/EigenLVRTaskHook.sol";

contract EigenLVRTaskHookTest is Test {
    EigenLVRTaskHook public taskHook;
    
    // Mock addresses
    address public constant MOCK_EIGENLVR_HOOK = address(0x1);
    address public constant MOCK_SERVICE_MANAGER = address(0x2);
    address public constant MOCK_CROSS_CHAIN_DETECTOR = address(0x3);
    address public constant MOCK_CALLER = address(0x4);
    
    function setUp() public {
        taskHook = new EigenLVRTaskHook(
            MOCK_EIGENLVR_HOOK, 
            MOCK_CROSS_CHAIN_DETECTOR,
            MOCK_SERVICE_MANAGER
        );
        
        vm.label(MOCK_EIGENLVR_HOOK, "MainEigenLVRHook");
        vm.label(MOCK_CROSS_CHAIN_DETECTOR, "CrossChainDetector");
        vm.label(MOCK_SERVICE_MANAGER, "ServiceManager");
        vm.label(MOCK_CALLER, "TaskCaller");
    }
    
    function testTaskHookDeployment() public {
        assertEq(taskHook.getEigenLVRHook(), MOCK_EIGENLVR_HOOK);
        console.log("Task hook correctly references main EigenLVR hook");
    }
    
    function testTaskTypeConstants() public {
        bytes32[] memory supportedTypes = taskHook.getSupportedTaskTypes();
        
        assertEq(supportedTypes.length, 10);
        console.log("Supports 10 EigenLVR task types");
        
        // Test that task types are properly defined
        assertTrue(supportedTypes[0] != bytes32(0), "LVR_MONITORING type defined");
        assertTrue(supportedTypes[1] != bytes32(0), "CROSS_CHAIN_PRICE_SYNC type defined");
        assertTrue(supportedTypes[2] != bytes32(0), "LVR_OPPORTUNITY_DETECTION type defined");
        assertTrue(supportedTypes[3] != bytes32(0), "AUCTION_CREATION type defined");
    }
    
    function testTaskFeeStructure() public {
        bytes32 monitoringType = keccak256("LVR_MONITORING");
        uint96 fee = taskHook.getTaskTypeFee(monitoringType);
        
        assertGt(fee, 0, "Monitoring task should have non-zero fee");
        console.log("LVR monitoring task fee:", fee);
        
        bytes32 settlementType = keccak256("SETTLEMENT");
        uint96 settlementFee = taskHook.getTaskTypeFee(settlementType);
        
        assertGt(settlementFee, fee, "Settlement should cost more than monitoring");
        console.log("Settlement task fee:", settlementFee);
    }
    
    function testTaskValidationBasic() public {
        // Create a minimal task payload
        bytes memory payload = abi.encodePacked(keccak256("LVR_MONITORING"));
        
        // This should not revert for valid task type
        try taskHook.validatePreTaskCreation(MOCK_CALLER, payload) {
            console.log("Basic task validation passed");
        } catch {
            fail("Basic task validation should not revert");
        }
    }
    
    function testConnectorPattern() public {
        // Test that this is a connector, not business logic
        console.log("Testing L2 connector pattern");
        
        // The task hook should:
        // 1. Interface with EigenLayer task system
        // 2. Reference the main EigenLVR hook (business logic)
        // 3. NOT implement auction logic itself
        
        assertEq(taskHook.getEigenLVRHook(), MOCK_EIGENLVR_HOOK, "Should reference main hook");
        
        // Test that it calculates fees (coordination function)
        bytes memory payload = abi.encodePacked(keccak256("LVR_MONITORING"));
        
        uint96 fee = taskHook.calculateTaskFee(payload);
        assertGt(fee, 0, "Should calculate task fees");
        
        console.log("L2 connector pattern test passed");
    }
    
    function testInvalidTaskType() public {
        bytes memory invalidPayload = abi.encodePacked(keccak256("INVALID_TYPE"));
        
        // Should revert for unsupported task type
        vm.expectRevert("Unsupported task type");
        taskHook.validatePreTaskCreation(MOCK_CALLER, invalidPayload);
        
        console.log("Invalid task type properly rejected");
    }
}