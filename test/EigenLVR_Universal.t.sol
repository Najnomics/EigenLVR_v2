// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {FHE, InEuint128, InEuint64} from "@fhenixprotocol/cofhe-contracts/FHE.sol";
import {CoFheTest} from "../context/cofhe-mock-contracts/contracts/CoFheTest.sol";

import {EigenLVR_Universal} from "../src/EigenLVR_Universal.sol";
import {CrossChainLVRDetector} from "../src/crosschain/CrossChainLVRDetector.sol";
import {ChainRegistry} from "../src/crosschain/ChainRegistry.sol";
import {PrivateAuctionManager} from "../src/privacy/PrivateAuctionManager.sol";
import {IAVSDirectory} from "../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../src/interfaces/IPriceOracle.sol";
import {IAcrossHubPool} from "../src/interfaces/IAcrossHubPool.sol";

// Mock contracts
contract MockPoolManager {
    function getHookPermissions(address) external pure returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }
}

contract MockAVSDirectory {
    mapping(address => mapping(address => bool)) public operatorRegistrations;
    
    function registerOperatorToAVS(address operator, bytes calldata) external {
        operatorRegistrations[msg.sender][operator] = true;
    }
    
    function isOperatorRegistered(address avs, address operator) external view returns (bool) {
        return operatorRegistrations[avs][operator];
    }
    
    function getOperatorStake(address, address) external pure returns (uint256) {
        return 1000 ether; // Mock stake
    }
}

contract MockPriceOracle {
    mapping(bytes32 => uint256) public prices;
    mapping(bytes32 => uint256) public timestamps;
    
    function setPrice(Currency token0, Currency token1, uint256 price) external {
        bytes32 key = keccak256(abi.encode(token0, token1));
        prices[key] = price;
        timestamps[key] = block.timestamp;
    }
    
    function getPrice(Currency token0, Currency token1) external view returns (uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return prices[key] > 0 ? prices[key] : 1e18; // Default 1:1 ratio
    }
    
    function getPriceWithTimestamp(Currency token0, Currency token1) external view returns (uint256, uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return (prices[key] > 0 ? prices[key] : 1e18, timestamps[key]);
    }
    
    function isPriceFresh(Currency, Currency, uint256) external pure returns (bool) {
        return true;
    }
    
    function getPriceConfidence(Currency, Currency) external pure returns (uint256) {
        return 10000; // 100% confidence
    }
}

contract MockAcrossHubPool {
    function depositV3(
        address,
        address,
        address,
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint32,
        uint32,
        uint32,
        bytes calldata
    ) external payable {
        // Mock implementation - just emit event or store data
    }
    
    function getBridgeFee(address, address, uint256, uint256) external pure returns (uint256) {
        return 1e15; // 0.001 ETH fee
    }
}

/**
 * @title EigenLVR_Universal Test Suite
 * @notice Comprehensive tests for the enhanced EigenLVR system
 */
contract EigenLVR_UniversalTest is Test, CoFheTest {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    
    /*//////////////////////////////////////////////////////////////
                                CONTRACTS
    //////////////////////////////////////////////////////////////*/
    
    EigenLVR_Universal public hook;
    CrossChainLVRDetector public detector;
    ChainRegistry public chainRegistry;
    PrivateAuctionManager public auctionManager;
    
    MockPoolManager public poolManager;
    MockAVSDirectory public avsDirectory;
    MockPriceOracle public priceOracle;
    MockAcrossHubPool public acrossHub;
    
    /*//////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////*/
    
    address constant ALICE = 0x1111111111111111111111111111111111111111;
    address constant BOB = 0x2222222222222222222222222222222222222222;
    address constant CHARLIE = 0x3333333333333333333333333333333333333333;
    address constant FEE_RECIPIENT = 0x4444444444444444444444444444444444444444;
    
    Currency constant CURRENCY0 = Currency.wrap(0x5555555555555555555555555555555555555555);
    Currency constant CURRENCY1 = Currency.wrap(0x6666666666666666666666666666666666666666);
    
    function setUp() public {
        // Deploy mock contracts
        poolManager = new MockPoolManager();
        avsDirectory = new MockAVSDirectory();
        priceOracle = new MockPriceOracle();
        acrossHub = new MockAcrossHubPool();
        
        // Deploy main contracts
        chainRegistry = new ChainRegistry();
        detector = new CrossChainLVRDetector();
        auctionManager = new PrivateAuctionManager();
        
        // Deploy the main hook
        hook = new EigenLVR_Universal(
            IPoolManager(address(poolManager)),
            IAVSDirectory(address(avsDirectory)),
            IPriceOracle(address(priceOracle)),
            IAcrossHubPool(address(acrossHub)),
            address(chainRegistry),
            address(detector),
            address(auctionManager),
            FEE_RECIPIENT,
            50 // 0.5% LVR threshold
        );
        
        // Setup permissions
        auctionManager.authorizeOperator(address(hook), true);
        detector.setAuthorizedUpdater(address(this), true);
        
        // Fund test accounts
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CHARLIE, 100 ether);
    }
    
    /*//////////////////////////////////////////////////////////////
                            HOOK TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testHookPermissions() public {
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        
        assertTrue(permissions.afterInitialize, "afterInitialize should be enabled");
        assertTrue(permissions.beforeAddLiquidity, "beforeAddLiquidity should be enabled");
        assertTrue(permissions.beforeRemoveLiquidity, "beforeRemoveLiquidity should be enabled");
        assertTrue(permissions.beforeSwap, "beforeSwap should be enabled");
        assertTrue(permissions.afterSwap, "afterSwap should be enabled");
        
        assertFalse(permissions.beforeInitialize, "beforeInitialize should be disabled");
        assertFalse(permissions.afterAddLiquidity, "afterAddLiquidity should be disabled");
        assertFalse(permissions.beforeDonate, "beforeDonate should be disabled");
    }
    
    function testAfterInitialize() public {
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Call afterInitialize (normally called by PoolManager)
        vm.prank(address(poolManager));
        bytes4 selector = hook.afterInitialize(address(this), key, 1e18, 0);
        
        assertEq(selector, BaseHook.afterInitialize.selector, "Should return correct selector");
    }
    
    /*//////////////////////////////////////////////////////////////
                        CROSS-CHAIN TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testCrossChainDetection() public {
        // Setup cross-chain price difference
        bytes32 tokenPair = keccak256(abi.encode(CURRENCY0, CURRENCY1));
        
        // Set prices on different chains
        detector.updateChainPrice(1, tokenPair, 3000e18, 10000); // Ethereum: $3000
        detector.updateChainPrice(42161, tokenPair, 3015e18, 10000); // Arbitrum: $3015
        
        // Create swap params
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 10e18, // 10 ETH swap
            sqrtPriceLimitX96: 0
        });
        
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // Test cross-chain detection
        (bool hasOpportunity,) = detector.detectCrossChainOpportunity(key, params);
        
        assertTrue(hasOpportunity, "Should detect cross-chain opportunity");
    }
    
    function testChainRegistry() public {
        // Test supported chains
        uint256[] memory supportedChains = chainRegistry.getSupportedChains();
        assertTrue(supportedChains.length > 0, "Should have supported chains");
        
        // Test chain configuration
        assertTrue(chainRegistry.isChainSupported(1), "Ethereum should be supported");
        assertTrue(chainRegistry.isChainSupported(42161), "Arbitrum should be supported");
        assertFalse(chainRegistry.isChainSupported(999999), "Random chain should not be supported");
        
        // Test chain info
        ChainRegistry.ChainConfig memory config = chainRegistry.getChainConfig(1);
        assertEq(config.chainId, 1, "Ethereum chain ID should be 1");
        assertEq(config.name, "Ethereum", "Should have correct name");
    }
    
    /*//////////////////////////////////////////////////////////////
                        PRIVATE AUCTION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testPrivateAuctionCreation() public {
        bytes32 auctionId = keccak256("test-auction-1");
        
        // Create encrypted auction parameters (simplified for testing)
        InEuint128 memory encMinBid = createInEuint128(uint128(1e18), ALICE); // 1 ETH min bid
        InEuint128 memory encReserve = createInEuint128(uint128(5e18), ALICE); // 5 ETH reserve
        InEuint64 memory encDuration = createInEuint64(uint64(300), ALICE); // 5 minutes
        
        vm.prank(ALICE);
        auctionManager.createPrivateAuction(auctionId, encMinBid, encReserve, encDuration);
        
        // Verify auction was created
        (address seller, bool isActive, uint256 deadline, uint256 bidCount) = 
            auctionManager.getAuctionInfo(auctionId);
        
        assertEq(seller, ALICE, "Seller should be Alice");
        assertTrue(isActive, "Auction should be active");
        assertGt(deadline, block.timestamp, "Deadline should be in future");
        assertEq(bidCount, 0, "Should start with no bids");
    }
    
    function testPrivateAuctionBidding() public {
        bytes32 auctionId = keccak256("test-auction-2");
        
        // Create auction first
        vm.prank(ALICE);
        InEuint128 memory encMinBid = createInEuint128(uint128(1e18), ALICE);
        InEuint128 memory encReserve = createInEuint128(uint128(5e18), ALICE);
        InEuint64 memory encDuration = createInEuint64(uint64(300), ALICE);
        auctionManager.createPrivateAuction(auctionId, encMinBid, encReserve, encDuration);
        
        // Submit encrypted bid
        vm.prank(BOB);
        InEuint128 memory encBid = createInEuint128(uint128(2e18), BOB); // 2 ETH bid
        auctionManager.submitEncryptedBid(auctionId, encBid);
        
        // Verify bid was submitted
        assertTrue(auctionManager.hasBid(auctionId, BOB), "Bob should have submitted a bid");
        
        // Check bid count updated
        (,, uint256 bidCount) = auctionManager.getAuctionInfo(auctionId);
        assertEq(bidCount, 1, "Should have one bid");
    }
    
    /*//////////////////////////////////////////////////////////////
                            LVR TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testLVRDetection() public {
        // Setup price difference to trigger LVR
        priceOracle.setPrice(CURRENCY0, CURRENCY1, 3000e18); // Pool price: $3000
        
        // Mock external price higher to create arbitrage opportunity
        bytes32 tokenPair = keccak256(abi.encode(CURRENCY0, CURRENCY1));
        detector.updateChainPrice(block.chainid, tokenPair, 3100e18, 10000); // External: $3100
        
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 10e18, // Significant swap
            sqrtPriceLimitX96: 0
        });
        
        // Test beforeSwap hook
        vm.prank(address(poolManager));
        (bytes4 selector,,) = hook.beforeSwap(address(this), key, params, "");
        
        assertEq(selector, BaseHook.beforeSwap.selector, "Should return correct selector");
    }
    
    /*//////////////////////////////////////////////////////////////
                        ADMIN TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testOperatorAuthorization() public {
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized initially");
        
        hook.setOperatorAuthorization(ALICE, true);
        assertTrue(hook.authorizedOperators(ALICE), "Alice should be authorized after setting");
        
        hook.setOperatorAuthorization(ALICE, false);
        assertFalse(hook.authorizedOperators(ALICE), "Alice should not be authorized after removal");
    }
    
    function testOnlyOwnerFunctions() public {
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setOperatorAuthorization(BOB, true);
        
        vm.prank(ALICE);
        vm.expectRevert();
        hook.setLVRThreshold(100);
    }
    
    function testLVRThresholdUpdate() public {
        uint256 oldThreshold = hook.lvrThreshold();
        uint256 newThreshold = 100; // 1%
        
        hook.setLVRThreshold(newThreshold);
        assertEq(hook.lvrThreshold(), newThreshold, "Threshold should be updated");
        
        // Test threshold too high
        vm.expectRevert("EigenLVR: threshold too high");
        hook.setLVRThreshold(2000); // 20% - too high
    }
    
    /*//////////////////////////////////////////////////////////////
                        INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/
    
    function testFullWorkflow() public {
        // 1. Setup pool and liquidity tracking
        PoolKey memory key = PoolKey({
            currency0: CURRENCY0,
            currency1: CURRENCY1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
        
        // 2. Initialize pool
        vm.prank(address(poolManager));
        hook.afterInitialize(address(this), key, 1e18, 0);
        
        // 3. Add liquidity
        ModifyLiquidityParams memory liquidity = ModifyLiquidityParams({
            tickLower: -60,
            tickUpper: 60,
            liquidityDelta: 1000e18
        });
        
        vm.prank(address(poolManager));
        hook.beforeAddLiquidity(ALICE, key, liquidity, "");
        
        // 4. Create LVR opportunity
        priceOracle.setPrice(CURRENCY0, CURRENCY1, 3000e18);
        bytes32 tokenPair = keccak256(abi.encode(CURRENCY0, CURRENCY1));
        detector.updateChainPrice(block.chainid, tokenPair, 3200e18, 10000);
        
        // 5. Execute swap that should trigger auction
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: 5e18,
            sqrtPriceLimitX96: 0
        });
        
        vm.prank(address(poolManager));
        (bytes4 selector,,) = hook.beforeSwap(address(this), key, params, "");
        
        assertEq(selector, BaseHook.beforeSwap.selector, "Should handle swap successfully");
    }
    
    /*//////////////////////////////////////////////////////////////
                            HELPERS
    //////////////////////////////////////////////////////////////*/
    
    function testReceiveETH() public {
        uint256 balanceBefore = address(hook).balance;
        
        (bool success,) = payable(address(hook)).call{value: 1 ether}("");
        assertTrue(success, "Should accept ETH");
        
        assertEq(address(hook).balance, balanceBefore + 1 ether, "Balance should increase");
    }
}