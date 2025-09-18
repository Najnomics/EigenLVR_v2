// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {EigenLVRTaskHook} from "../src/l2-contracts/EigenLVRTaskHook.sol";

contract DeployEigenLVRL2Contracts is Script {
    using stdJson for string;

    struct Context {
        address avs;
        uint256 avsPrivateKey;
        uint256 deployerPrivateKey;
        address eigenLVRHook;  // Address of the main EigenLVR Hook (deployed separately)
        address crossChainDetector;  // Address of the cross-chain detector
        address serviceManager;  // Address of the L1 service manager
    }

    struct Output {
        string name;
        address contractAddress;
    }

    function run(string memory environment, string memory _context) public {
        // Read the context
        Context memory context = _readContext(environment, _context);

        vm.startBroadcast(context.deployerPrivateKey);
        console.log("Deployer address:", vm.addr(context.deployerPrivateKey));

        // Deploy EigenLVR Task Hook (connector to main hook)
        EigenLVRTaskHook taskHook = new EigenLVRTaskHook(
            context.eigenLVRHook,
            context.crossChainDetector,
            context.serviceManager
        );
        console.log("EigenLVRTaskHook deployed to:", address(taskHook));
        console.log("Connected to main EigenLVR Hook at:", context.eigenLVRHook);
        console.log("Connected to cross-chain detector at:", context.crossChainDetector);
        console.log("Connected to service manager at:", context.serviceManager);

        vm.stopBroadcast();

        vm.startBroadcast(context.avsPrivateKey);
        console.log("AVS address:", context.avs);

        // TODO: Implement any additional L2 setup for task hook
        // - Configure task fees
        // - Set up task type validations
        // - Connect with main EigenLVR Hook
        // - Configure cross-chain monitoring

        vm.stopBroadcast();

        // Output the deployed contracts
        Output[] memory outputs = new Output[](1);
        outputs[0] = Output("EigenLVRTaskHook", address(taskHook));

        _writeOutput(environment, outputs);
    }

    function _readContext(string memory environment, string memory _context) internal view returns (Context memory) {
        string memory contextJson = vm.readFile(string.concat(".hourglass/context/", environment, ".json"));

        Context memory context;
        context.avs = contextJson.readAddress(".avs.address");
        context.avsPrivateKey = contextJson.readUint(".avs.privateKey");
        context.deployerPrivateKey = contextJson.readUint(".deployer.privateKey");
        
        // Read L2-specific configuration for connector
        context.eigenLVRHook = contextJson.readAddress(".l2.eigenLVRHook");  // Main hook address
        context.crossChainDetector = contextJson.readAddress(".l2.crossChainDetector");  // Cross-chain detector
        context.serviceManager = contextJson.readAddress(".l1.serviceManager");  // L1 service manager

        return context;
    }

    function _writeOutput(string memory environment, Output[] memory outputs) internal {
        string memory outputDir = string.concat(".hourglass/context/", environment, "/");
        string memory outputFile = string.concat(outputDir, "eigenlvr-l2-contracts.json");

        string memory json = "";
        for (uint256 i = 0; i < outputs.length; i++) {
            json = vm.serializeAddress(json, outputs[i].name, outputs[i].contractAddress);
        }

        vm.writeFile(outputFile, json);
        console.log("EigenLVR L2 contract addresses written to:", outputFile);
    }
}