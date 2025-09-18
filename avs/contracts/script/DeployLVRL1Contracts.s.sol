// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {EigenLVRServiceManager} from "../src/l1-contracts/EigenLVRServiceManager.sol";

contract DeployEigenLVRL1Contracts is Script {
    using stdJson for string;

    struct Context {
        address avs;
        uint256 avsPrivateKey;
        uint256 deployerPrivateKey;
        IAVSDirectory avsDirectory;
        address eigenLVRHookL2;
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

        // Deploy EigenLVR Service Manager
        EigenLVRServiceManager eigenLVRServiceManager = new EigenLVRServiceManager(
            context.avsDirectory,
            context.eigenLVRHookL2
        );
        console.log("EigenLVRServiceManager deployed to:", address(eigenLVRServiceManager));

        vm.stopBroadcast();

        vm.startBroadcast(context.avsPrivateKey);
        console.log("AVS address:", context.avs);

        // TODO: Implement any additional AVS setup for EigenLVR
        // - Configure LVR detection parameters
        // - Set up cross-chain monitoring
        // - Initialize FHE auction requirements

        vm.stopBroadcast();

        // Output the deployed contracts
        Output[] memory outputs = new Output[](1);
        outputs[0] = Output("EigenLVRServiceManager", address(eigenLVRServiceManager));

        _writeOutput(environment, outputs);
    }

    function _readContext(string memory environment, string memory _context) internal view returns (Context memory) {
        string memory contextJson = vm.readFile(string.concat(".hourglass/context/", environment, ".json"));

        Context memory context;
        context.avs = contextJson.readAddress(".avs.address");
        context.avsPrivateKey = contextJson.readUint(".avs.privateKey");
        context.deployerPrivateKey = contextJson.readUint(".deployer.privateKey");
        context.avsDirectory = IAVSDirectory(contextJson.readAddress(".contracts.avsDirectory"));
        context.eigenLVRHookL2 = contextJson.readAddress(".contracts.eigenLVRHookL2");

        return context;
    }

    function _writeOutput(string memory environment, Output[] memory outputs) internal {
        string memory outputDir = string.concat(".hourglass/context/", environment, "/");
        string memory outputFile = string.concat(outputDir, "eigenlvr-l1-contracts.json");

        string memory json = "";
        for (uint256 i = 0; i < outputs.length; i++) {
            json = vm.serializeAddress(json, outputs[i].name, outputs[i].contractAddress);
        }

        vm.writeFile(outputFile, json);
        console.log("EigenLVR L1 contract addresses written to:", outputFile);
    }
}