// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {EigenLVR_Universal} from "../src/EigenLVR_Universal.sol";
import {CrossChainLVRDetector} from "../src/crosschain/CrossChainLVRDetector.sol";
import {ChainRegistry} from "../src/crosschain/ChainRegistry.sol";
import {PrivateAuctionManager} from "../src/privacy/PrivateAuctionManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../src/interfaces/IPriceOracle.sol";
import {IAcrossHubPool} from "../src/interfaces/IAcrossHubPool.sol";

/**
 * @title DeployEigenLVRv2
 * @notice Deployment script for EigenLVR v2 system
 * @dev Deploys all components of the enhanced system
 */
contract DeployEigenLVRv2 is Script {
    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT CONFIG
    //////////////////////////////////////////////////////////////*/
    
    // Mock addresses for local testing - replace with actual addresses for mainnet
    address constant MOCK_POOL_MANAGER = 0x8c4BcbE6b9ef47354169cDE11669E64db2bb9fd0;
    address constant MOCK_AVS_DIRECTORY = 0x135ddaA4e3d9c0B63e84bDA24E21e5c7Cef6F916;
    address constant MOCK_PRICE_ORACLE = 0x04f5e2B9e7e5D8E3b64B3b4f8B1D5F12ab3f5b6C;
    address constant MOCK_ACROSS_HUB = 0x9B4BCbE6B9Ef47354169Cde11669E64db2BB9fd0;
    
    address constant FEE_RECIPIENT = 0x1234567890123456789012345678901234567890;
    uint256 constant LVR_THRESHOLD = 50; // 0.5% threshold
    
    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT
    //////////////////////////////////////////////////////////////*/
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying EigenLVR v2 with deployer:", deployer);
        console2.log("Chain ID:", block.chainid);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy supporting components first
        console2.log("Deploying ChainRegistry...");
        ChainRegistry chainRegistry = new ChainRegistry();
        
        console2.log("Deploying CrossChainLVRDetector...");
        CrossChainLVRDetector detector = new CrossChainLVRDetector();
        
        console2.log("Deploying PrivateAuctionManager...");
        PrivateAuctionManager auctionManager = new PrivateAuctionManager();
        
        // 2. Deploy main EigenLVR_Universal contract
        console2.log("Deploying EigenLVR_Universal...");
        EigenLVR_Universal hook = new EigenLVR_Universal(
            IPoolManager(MOCK_POOL_MANAGER),
            IAVSDirectory(MOCK_AVS_DIRECTORY),
            IPriceOracle(MOCK_PRICE_ORACLE),
            IAcrossHubPool(MOCK_ACROSS_HUB),
            address(chainRegistry),
            address(detector),
            address(auctionManager),
            FEE_RECIPIENT,
            LVR_THRESHOLD
        );
        
        // 3. Configure permissions and authorizations
        console2.log("Configuring system permissions...");
        
        // Authorize the hook contract as an operator in the auction manager
        auctionManager.authorizeOperator(address(hook), true);
        
        // Add deployer as authorized price updater for cross-chain detector
        detector.setAuthorizedUpdater(deployer, true);
        
        vm.stopBroadcast();
        
        // 4. Log deployment addresses
        console2.log("=== EigenLVR v2 Deployment Complete ===");
        console2.log("ChainRegistry:", address(chainRegistry));
        console2.log("CrossChainLVRDetector:", address(detector));
        console2.log("PrivateAuctionManager:", address(auctionManager));
        console2.log("EigenLVR_Universal:", address(hook));
        console2.log("=======================================");
        
        // 5. Verify deployment
        _verifyDeployment(
            address(chainRegistry),
            address(detector), 
            address(auctionManager),
            payable(address(hook))
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                            VERIFICATION
    //////////////////////////////////////////////////////////////*/
    
    function _verifyDeployment(
        address chainRegistry,
        address detector,
        address auctionManager,
        address payable hook
    ) internal view {
        console2.log("Verifying deployment...");
        
        // Verify chain registry has supported chains
        uint256[] memory supportedChains = ChainRegistry(chainRegistry).getSupportedChains();
        console2.log("Supported chains count:", supportedChains.length);
        require(supportedChains.length > 0, "No supported chains configured");
        
        // Verify detector configuration
        require(CrossChainLVRDetector(detector).supportedChains(1), "Ethereum not supported");
        require(CrossChainLVRDetector(detector).supportedChains(42161), "Arbitrum not supported");
        
        // Verify auction manager authorization
        require(
            PrivateAuctionManager(auctionManager).authorizedOperators(hook),
            "Hook not authorized in auction manager"
        );
        
        // Verify hook configuration
        require(address(EigenLVR_Universal(hook).chainRegistry()) == chainRegistry, "Chain registry mismatch");
        require(address(EigenLVR_Universal(hook).crossChainDetector()) == detector, "Detector mismatch");
        require(address(EigenLVR_Universal(hook).privateAuctionManager()) == auctionManager, "Auction manager mismatch");
        
        console2.log("All deployment verifications passed!");
    }
}