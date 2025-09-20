// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {EigenLVR_V2} from "../src/hook/EigenLVR_V2.sol";
import {CrossChainPriceMonitor} from "../src/crosschain/CrossChainPriceMonitor.sol";
import {PrivateAuctionManager} from "../src/privacy/PrivateAuctionManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../src/interfaces/IPriceOracle.sol";

/**
 * @title DeployAnvil
 * @notice Anvil-specific deployment script for EigenLVR v2
 * @dev Optimized for local development with mock addresses and test configurations
 */
contract DeployAnvil is Script {
    /*//////////////////////////////////////////////////////////////
                            ANVIL CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    
    // Anvil test addresses (first 10 accounts from anvil --accounts)
    address constant ANVIL_ACCOUNT_0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant ANVIL_ACCOUNT_1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant ANVIL_ACCOUNT_2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant ANVIL_ACCOUNT_3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address constant ANVIL_ACCOUNT_4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
    
    // Mock contract addresses for Anvil (we'll deploy these first)
    address public mockPoolManager;
    address public mockAVSDirectory;
    address public mockPriceOracle;
    
    // Anvil configuration
    uint256 constant ANVIL_CHAIN_ID = 31337;
    address constant FEE_RECIPIENT = ANVIL_ACCOUNT_1; // Use second account as fee recipient
    uint256 constant LVR_THRESHOLD = 50; // 0.5%
    
    // Test configuration
    uint256 constant INITIAL_ETH_PRICE = 3000e18; // $3000 ETH
    uint256 constant INITIAL_USDC_PRICE = 1e6; // $1 USDC
    
    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT
    //////////////////////////////////////////////////////////////*/
    
    function run() external {
        // Use default Anvil private key
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("=== EigenLVR v2 Anvil Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Chain ID:", block.chainid);
        console2.log("Block Number:", block.number);
        console2.log("Gas Price:", tx.gasprice);
        console2.log("Gas Limit:", block.gaslimit);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy Mock Contracts for Anvil
        console2.log("\n--- Deploying Mock Contracts ---");
        _deployMockContracts();
        
        // 2. Deploy Cross-Chain Price Monitor
        console2.log("\n--- Deploying CrossChainPriceMonitor ---");
        CrossChainPriceMonitor priceMonitor = new CrossChainPriceMonitor();
        console2.log("CrossChainPriceMonitor deployed at:", address(priceMonitor));
        
        // 3. Deploy Private Auction Manager
        console2.log("\n--- Deploying PrivateAuctionManager ---");
        PrivateAuctionManager auctionManager = new PrivateAuctionManager();
        console2.log("PrivateAuctionManager deployed at:", address(auctionManager));
        
        // 4. Deploy main EigenLVR_V2 Hook
        console2.log("\n--- Deploying EigenLVR_V2 Hook ---");
        EigenLVR_V2 hook = new EigenLVR_V2(
            IPoolManager(mockPoolManager),
            IAVSDirectory(mockAVSDirectory),
            IPriceOracle(mockPriceOracle),
            address(priceMonitor),
            address(auctionManager),
            FEE_RECIPIENT,
            LVR_THRESHOLD
        );
        console2.log("EigenLVR_V2 deployed at:", address(hook));
        
        // 5. Configure System Permissions
        console2.log("\n--- Configuring System Permissions ---");
        _configurePermissions(hook, auctionManager, priceMonitor, deployer);
        
        // 6. Setup Test Data
        console2.log("\n--- Setting Up Test Data ---");
        _setupTestData(priceMonitor, hook);
        
        vm.stopBroadcast();
        
        // 7. Verify Deployment
        console2.log("\n--- Verifying Deployment ---");
        _verifyDeployment(hook, priceMonitor, auctionManager);
        
        // 8. Generate Test Configuration
        console2.log("\n--- Generating Test Configuration ---");
        _generateTestConfig(address(hook), address(priceMonitor), address(auctionManager));
        
        console2.log("\n=== Anvil Deployment Complete ===");
    }
    
    /*//////////////////////////////////////////////////////////////
                            MOCK CONTRACTS
    //////////////////////////////////////////////////////////////*/
    
    function _deployMockContracts() internal {
        // Deploy Mock Pool Manager
        MockPoolManager poolManager = new MockPoolManager();
        mockPoolManager = address(poolManager);
        console2.log("MockPoolManager deployed at:", mockPoolManager);
        
        // Deploy Mock AVS Directory
        MockAVSDirectory avsDirectory = new MockAVSDirectory();
        mockAVSDirectory = address(avsDirectory);
        console2.log("MockAVSDirectory deployed at:", mockAVSDirectory);
        
        // Deploy Mock Price Oracle
        MockPriceOracle priceOracle = new MockPriceOracle();
        mockPriceOracle = address(priceOracle);
        console2.log("MockPriceOracle deployed at:", mockPriceOracle);
        
        // Initialize mock contracts with test data
        _initializeMockContracts(poolManager, avsDirectory, priceOracle);
    }
    
    function _initializeMockContracts(
        MockPoolManager poolManager,
        MockAVSDirectory avsDirectory,
        MockPriceOracle priceOracle
    ) internal {
        // Initialize price oracle with test prices
        priceOracle.setPrice("ETH/USDC", INITIAL_ETH_PRICE);
        priceOracle.setPrice("USDC/ETH", 1e36 / INITIAL_ETH_PRICE); // Inverse price
        priceOracle.setPrice("WETH/USDC", INITIAL_ETH_PRICE);
        
        // Initialize AVS directory with test operators
        avsDirectory.registerOperator(ANVIL_ACCOUNT_2, "TestOperator1");
        avsDirectory.registerOperator(ANVIL_ACCOUNT_3, "TestOperator2");
        avsDirectory.registerOperator(ANVIL_ACCOUNT_4, "TestOperator3");
        
        // Set operator stakes
        avsDirectory.setOperatorStake(ANVIL_ACCOUNT_2, 1000e18);
        avsDirectory.setOperatorStake(ANVIL_ACCOUNT_3, 2000e18);
        avsDirectory.setOperatorStake(ANVIL_ACCOUNT_4, 1500e18);
        
        console2.log("Mock contracts initialized with test data");
    }
    
    /*//////////////////////////////////////////////////////////////
                            PERMISSIONS
    //////////////////////////////////////////////////////////////*/
    
    function _configurePermissions(
        EigenLVR_V2 hook,
        PrivateAuctionManager auctionManager,
        CrossChainPriceMonitor priceMonitor,
        address deployer
    ) internal {
        // Authorize hook as operator in auction manager
        auctionManager.authorizeOperator(address(hook), true);
        console2.log("Hook authorized in auction manager");
        
        // Add deployer as price updater for testing
        priceMonitor.setAuthorizedUpdater(deployer, true);
        console2.log("Deployer authorized as price updater");
        
        // Add test accounts as authorized operators
        hook.setOperatorAuthorization(ANVIL_ACCOUNT_2, true);
        hook.setOperatorAuthorization(ANVIL_ACCOUNT_3, true);
        hook.setOperatorAuthorization(ANVIL_ACCOUNT_4, true);
        console2.log("Test accounts authorized as operators");
    }
    
    /*//////////////////////////////////////////////////////////////
                            TEST DATA
    //////////////////////////////////////////////////////////////*/
    
    function _setupTestData(
        CrossChainPriceMonitor priceMonitor,
        EigenLVR_V2 hook
    ) internal {
        // Setup cross-chain price monitoring for test chains
        uint256[] memory chainIds = new uint256[](4);
        chainIds[0] = 1;      // Ethereum
        chainIds[1] = 42161;  // Arbitrum
        chainIds[2] = 10;     // Optimism
        chainIds[3] = 137;    // Polygon
        
        bytes32[] memory pairs = new bytes32[](4);
        uint256[] memory prices = new uint256[](4);
        uint256[] memory confidences = new uint256[](4);
        
        // Set up ETH/USDC prices with slight variations
        for (uint256 i = 0; i < chainIds.length; i++) {
            pairs[i] = keccak256("ETH/USDC");
            prices[i] = INITIAL_ETH_PRICE + (i * 10e18); // $3000, $3010, $3020, $3030
            confidences[i] = 9500; // 95% confidence
        }
        
        priceMonitor.batchUpdatePrices(chainIds, pairs, prices, confidences);
        console2.log("Cross-chain price feeds configured");
        
        // Set up additional test pairs
        _setupAdditionalPriceFeeds(priceMonitor);
    }
    
    function _setupAdditionalPriceFeeds(CrossChainPriceMonitor priceMonitor) internal {
        // Setup BTC/USDC prices
        uint256[] memory btcChainIds = new uint256[](2);
        btcChainIds[0] = 1;
        btcChainIds[1] = 42161;
        
        bytes32[] memory btcPairs = new bytes32[](2);
        uint256[] memory btcPrices = new uint256[](2);
        uint256[] memory btcConfidences = new uint256[](2);
        
        btcPairs[0] = keccak256("BTC/USDC");
        btcPairs[1] = keccak256("BTC/USDC");
        btcPrices[0] = 45000e18; // $45,000
        btcPrices[1] = 45100e18; // $45,100
        btcConfidences[0] = 9200; // 92% confidence
        btcConfidences[1] = 9200;
        
        priceMonitor.batchUpdatePrices(btcChainIds, btcPairs, btcPrices, btcConfidences);
        console2.log("Additional price feeds configured");
    }
    
    /*//////////////////////////////////////////////////////////////
                            VERIFICATION
    //////////////////////////////////////////////////////////////*/
    
    function _verifyDeployment(
        EigenLVR_V2 hook,
        CrossChainPriceMonitor priceMonitor,
        PrivateAuctionManager auctionManager
    ) internal view {
        console2.log("Verifying deployment...");
        
        // Verify hook permissions
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        require(permissions.afterInitialize, "afterInitialize not enabled");
        require(permissions.beforeSwap, "beforeSwap not enabled");
        require(permissions.afterSwap, "afterSwap not enabled");
        console2.log("[OK] Hook permissions verified");
        
        // Verify cross-chain monitor
        require(address(hook.crossChainMonitor()) == address(priceMonitor), "Price monitor mismatch");
        console2.log("[OK] Cross-chain monitor verified");
        
        // Verify auction manager
        require(address(hook.privateAuctionManager()) == address(auctionManager), "Auction manager mismatch");
        console2.log("[OK] Auction manager verified");
        
        // Verify operator authorization
        require(hook.authorizedOperators(ANVIL_ACCOUNT_2), "Operator 2 not authorized");
        require(hook.authorizedOperators(ANVIL_ACCOUNT_3), "Operator 3 not authorized");
        require(hook.authorizedOperators(ANVIL_ACCOUNT_4), "Operator 4 not authorized");
        console2.log("[OK] Operator authorizations verified");
        
        // Verify price feeds
        uint256[] memory supportedChains = priceMonitor.getSupportedChains();
        require(supportedChains.length > 0, "No supported chains");
        console2.log("[OK] Price feeds verified (", supportedChains.length, " chains)");
        
        console2.log("All deployment verifications passed!");
    }
    
    /*//////////////////////////////////////////////////////////////
                            TEST CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    
    function _generateTestConfig(
        address hook,
        address priceMonitor,
        address auctionManager
    ) internal view {
        console2.log("=== Anvil Test Configuration ===");
        console2.log("HOOK_ADDRESS=", hook);
        console2.log("PRICE_MONITOR_ADDRESS=", priceMonitor);
        console2.log("AUCTION_MANAGER_ADDRESS=", auctionManager);
        console2.log("MOCK_POOL_MANAGER=", mockPoolManager);
        console2.log("MOCK_AVS_DIRECTORY=", mockAVSDirectory);
        console2.log("MOCK_PRICE_ORACLE=", mockPriceOracle);
        console2.log("FEE_RECIPIENT=", FEE_RECIPIENT);
        console2.log("CHAIN_ID=", block.chainid);
        console2.log("DEPLOYMENT_BLOCK=", block.number);
        console2.log("================================");
        
        console2.log("\n=== Test Accounts ===");
        console2.log("Account 0 (Deployer):", ANVIL_ACCOUNT_0);
        console2.log("Account 1 (Fee Recipient):", ANVIL_ACCOUNT_1);
        console2.log("Account 2 (Operator):", ANVIL_ACCOUNT_2);
        console2.log("Account 3 (Operator):", ANVIL_ACCOUNT_3);
        console2.log("Account 4 (Operator):", ANVIL_ACCOUNT_4);
        console2.log("======================");
        
        console2.log("\n=== Next Steps ===");
        console2.log("1. Run tests: forge test --fork-url http://localhost:8545");
        console2.log("2. Test hook integration: forge test --match-test testHook");
        console2.log("3. Test LVR detection: forge test --match-test testLVR");
        console2.log("4. Test private auctions: forge test --match-test testPrivate");
        console2.log("5. Monitor events: cast logs --address", hook);
        console2.log("==================");
    }
}

/*//////////////////////////////////////////////////////////////
                            MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

/**
 * @title MockPoolManager
 * @notice Mock implementation of IPoolManager for Anvil testing
 */
contract MockPoolManager {
    mapping(bytes32 => address) public pools;
    
    function createPool(bytes32 poolId, address pool) external {
        pools[poolId] = pool;
    }
    
    function getPool(bytes32 poolId) external view returns (address) {
        return pools[poolId];
    }
}

/**
 * @title MockAVSDirectory
 * @notice Mock implementation of IAVSDirectory for Anvil testing
 */
contract MockAVSDirectory {
    mapping(address => bool) public registeredOperators;
    mapping(address => string) public operatorNames;
    mapping(address => uint256) public operatorStakes;
    
    function registerOperator(address operator, string memory name) external {
        registeredOperators[operator] = true;
        operatorNames[operator] = name;
    }
    
    function setOperatorStake(address operator, uint256 stake) external {
        operatorStakes[operator] = stake;
    }
    
    function getOperatorStake(address operator) external view returns (uint256) {
        return operatorStakes[operator];
    }
    
    function isRegistered(address operator) external view returns (bool) {
        return registeredOperators[operator];
    }
}

/**
 * @title MockPriceOracle
 * @notice Mock implementation of IPriceOracle for Anvil testing
 */
contract MockPriceOracle {
    mapping(string => uint256) public prices;
    
    function setPrice(string memory symbol, uint256 price) external {
        prices[symbol] = price;
    }
    
    function getPrice(string memory symbol) external view returns (uint256) {
        return prices[symbol];
    }
}
