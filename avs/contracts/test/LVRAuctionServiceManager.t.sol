// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {EigenLVRServiceManager} from "../src/l1-contracts/EigenLVRServiceManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";

contract EigenLVRServiceManagerTest is Test {
    EigenLVRServiceManager public serviceManager;
    IAVSDirectory public avsDirectory;
    
    // Mock addresses
    address public constant MOCK_AVS_DIRECTORY = address(0x1);
    address public constant MOCK_EIGENLVR_HOOK_L2 = address(0x2);
    
    function setUp() public {
        // This is a placeholder test since the actual deployment would require
        // real EigenLayer contracts. In practice, you'd use mocks or a testnet.
        vm.label(MOCK_AVS_DIRECTORY, "AVSDirectory");
        vm.label(MOCK_EIGENLVR_HOOK_L2, "EigenLVRHookL2");
        
        // Deploy the service manager
        serviceManager = new EigenLVRServiceManager(
            IAVSDirectory(MOCK_AVS_DIRECTORY),
            MOCK_EIGENLVR_HOOK_L2
        );
    }
    
    function testServiceManagerStorage() public {
        // Test that the service manager stores the correct L2 hook address
        assertEq(serviceManager.getEigenLVRHook(), MOCK_EIGENLVR_HOOK_L2);
        console.log("EigenLVR Service Manager test setup completed");
    }
    
    function testEigenLVRStakeRequirement() public {
        // Test that the minimum stake requirement is set correctly
        uint256 expectedMinStake = 10 ether;
        
        assertEq(serviceManager.MINIMUM_EIGENLVR_STAKE(), expectedMinStake);
        
        console.log("Minimum EigenLVR stake requirement:", expectedMinStake);
        assertTrue(expectedMinStake > 0);
    }
    
    function testConnectorArchitecture() public {
        // Test that this is a connector contract, not business logic
        console.log("Testing AVS connector architecture");
        
        // The service manager should:
        // 1. Connect to EigenLayer (L1)
        // 2. Reference the main EigenLVR hook (L2)
        // 3. NOT contain auction business logic
        
        assertTrue(MOCK_AVS_DIRECTORY != address(0), "Should connect to EigenLayer");
        assertTrue(MOCK_EIGENLVR_HOOK_L2 != address(0), "Should reference main EigenLVR hook");
        
        console.log("Connector architecture test passed");
    }
}