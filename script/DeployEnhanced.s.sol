// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {EigenLVR_V2} from "../src/EigenLVR_V2.sol";
import {CrossChainPriceMonitor} from "../src/crosschain/CrossChainPriceMonitor.sol";
import {PrivateAuctionManager} from "../src/privacy/PrivateAuctionManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../src/interfaces/IPriceOracle.sol";

/**
 * @title DeployEnhanced
 * @notice Production-ready deployment script for EigenLVR Enhanced system
 * @dev Deploys focused, practical components without over-ambitious features
 */
contract DeployEnhanced is Script {
    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT CONFIG
    //////////////////////////////////////////////////////////////*/
    
    // Production addresses - replace with actual deployment addresses
    address constant POOL_MANAGER = 0x8c4BcbE6b9ef47354169cDE11669E64db2bb9fd0;
    address constant AVS_DIRECTORY = 0x135ddaA4e3d9c0B63e84bDA24E21e5c7Cef6F916;
    address constant PRICE_ORACLE = 0x04f5e2B9e7e5D8E3b64B3b4f8B1D5F12ab3f5b6C;
    
    address constant FEE_RECIPIENT = 0x742d35Cc6608c8B29a1B8D9c0f6f8aD5B7c8B0A1;
    uint256 constant LVR_THRESHOLD = 50; // 0.5% - proven threshold from v1
    
    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT
    //////////////////////////////////////////////////////////////*/
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("=== EigenLVR Enhanced Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Chain ID:", block.chainid);
        console2.log("Gas Price:", tx.gasprice);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy Cross-Chain Price Monitor (read-only, no bridging)
        console2.log("Deploying CrossChainPriceMonitor...");
        CrossChainPriceMonitor priceMonitor = new CrossChainPriceMonitor();
        
        // 2. Deploy Private Auction Manager (FHE integration)
        console2.log("Deploying PrivateAuctionManager...");
        PrivateAuctionManager auctionManager = new PrivateAuctionManager();
        
        // 3. Deploy main V2 Hook
        console2.log("Deploying EigenLVR_V2...");
        EigenLVR_V2 hook = new EigenLVR_V2(
            IPoolManager(POOL_MANAGER),
            IAVSDirectory(AVS_DIRECTORY),
            IPriceOracle(PRICE_ORACLE),
            address(priceMonitor),
            address(auctionManager),
            FEE_RECIPIENT,
            LVR_THRESHOLD
        );
        
        // 4. Configure system permissions
        console2.log("Configuring system permissions...");
        
        // Authorize hook as operator in auction manager
        auctionManager.authorizeOperator(address(hook), true);
        
        // Add deployer as price updater (for initial setup)
        priceMonitor.setAuthorizedUpdater(deployer, true);
        
        // 5. Setup initial cross-chain price monitoring
        console2.log("Setting up cross-chain monitoring...");
        _setupInitialPriceFeeds(priceMonitor);
        
        vm.stopBroadcast();
        
        // 6. Log deployment summary
        console2.log("=== Deployment Complete ===");
        console2.log("CrossChainPriceMonitor:", address(priceMonitor));
        console2.log("PrivateAuctionManager:", address(auctionManager));
        console2.log("EigenLVR_V2:", address(hook));
        console2.log("================================");
        
        // 7. Verify deployment
        _verifyDeployment(
            address(priceMonitor),
            address(auctionManager),
            payable(address(hook))
        );
        
        // 8. Generate configuration files for AVS
        _generateAVSConfig(
            address(hook),
            address(priceMonitor),
            address(auctionManager)
        );
    }
    
    /*//////////////////////////////////////////////////////////////
                            CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    
    function _setupInitialPriceFeeds(CrossChainPriceMonitor monitor) internal {
        console2.log("Setting up initial price feeds...");
        
        // Initialize with sample prices (in production, would use real oracles)
        uint256[] memory chainIds = new uint256[](5);
        chainIds[0] = 1;     // Ethereum
        chainIds[1] = 42161; // Arbitrum
        chainIds[2] = 10;    // Optimism
        chainIds[3] = 137;   // Polygon
        chainIds[4] = 8453;  // Base
        
        bytes32[] memory pairs = new bytes32[](5);
        uint256[] memory prices = new uint256[](5);
        uint256[] memory confidences = new uint256[](5);
        
        // ETH/USDC prices with slight variations
        for (uint256 i = 0; i < chainIds.length; i++) {
            pairs[i] = keccak256("ETH/USDC");
            prices[i] = 3000e18 + (i * 5e18); // $3000-$3020 range
            confidences[i] = 9500; // 95% confidence
        }
        
        monitor.batchUpdatePrices(chainIds, pairs, prices, confidences);
        
        console2.log("Initial price feeds configured");
    }
    
    /*//////////////////////////////////////////////////////////////
                            VERIFICATION
    //////////////////////////////////////////////////////////////*/
    
    function _verifyDeployment(
        address priceMonitor,
        address auctionManager,
        address payable hook
    ) internal view {
        console2.log("Verifying deployment...");
        
        // Verify price monitor
        uint256[] memory supportedChains = CrossChainPriceMonitor(priceMonitor).getSupportedChains();
        require(supportedChains.length > 0, "No supported chains");
        console2.log("Price monitor supports", supportedChains.length, "chains");
        
        // Verify auction manager
        require(
            PrivateAuctionManager(auctionManager).authorizedOperators(hook),
            "Hook not authorized in auction manager"
        );
        console2.log("Hook authorized in auction manager");
        
        // Verify hook configuration
        require(
            address(EigenLVR_V2(hook).crossChainMonitor()) == priceMonitor,
            "Price monitor mismatch"
        );
        require(
            address(EigenLVR_V2(hook).privateAuctionManager()) == auctionManager,
            "Auction manager mismatch"
        );
        console2.log("Hook configuration verified");
        
        // Verify hook permissions
        Hooks.Permissions memory permissions = EigenLVR_V2(hook).getHookPermissions();
        require(permissions.afterInitialize, "afterInitialize not enabled");
        require(permissions.beforeSwap, "beforeSwap not enabled");
        require(permissions.afterSwap, "afterSwap not enabled");
        console2.log("Hook permissions verified");
        
        console2.log("All deployment verifications passed!");
    }
    
    /*//////////////////////////////////////////////////////////////
                            AVS CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    
    function _generateAVSConfig(
        address hook,
        address priceMonitor,
        address auctionManager
    ) internal view {
        console2.log("Generating AVS configuration...");
        
        console2.log("=== AVS Configuration ===");
        console2.log("Add these addresses to your AVS operator configs:");
        console2.log("HOOK_ADDRESS=", hook);
        console2.log("PRICE_MONITOR_ADDRESS=", priceMonitor);
        console2.log("AUCTION_MANAGER_ADDRESS=", auctionManager);
        console2.log("CHAIN_ID=", block.chainid);
        console2.log("DEPLOYMENT_BLOCK=", block.number);
        console2.log("============================");
        
        console2.log("Next steps:");
        console2.log("1. Update AVS operator configs with above addresses");
        console2.log("2. Start price feed operators for cross-chain monitoring");
        console2.log("3. Test private auction functionality");
        console2.log("4. Monitor system performance and adjust parameters");
    }
}

