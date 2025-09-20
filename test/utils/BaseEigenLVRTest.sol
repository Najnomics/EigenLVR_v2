// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {EigenLVR_V2} from "../../src/hook/EigenLVR_V2.sol";
import {IAVSDirectory} from "../../src/interfaces/IAVSDirectory.sol";
import {IPriceOracle} from "../../src/interfaces/IPriceOracle.sol";
import {HookMiner} from "./HookMiner.sol";

/**
 * @title BaseEigenLVRTest
 * @notice Base test contract that handles proper hook deployment with valid addresses
 * @dev All EigenLVR tests should inherit from this contract
 */
abstract contract BaseEigenLVRTest is Test {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    /*//////////////////////////////////////////////////////////////
                            TEST CONTRACTS
    //////////////////////////////////////////////////////////////*/
    
    EigenLVR_V2 public hook;
    
    // Mock contracts
    MockPoolManager public poolManager;
    MockAVSDirectory public avsDirectory;
    MockPriceOracle public priceOracle;
    MockCrossChainPriceMonitor public crossChainMonitor;
    MockPrivateAuctionManager public privateAuctionManager;

    /*//////////////////////////////////////////////////////////////
                            TEST DATA
    //////////////////////////////////////////////////////////////*/
    
    address constant ALICE = 0x1111111111111111111111111111111111111111;
    address constant BOB = 0x2222222222222222222222222222222222222222;
    address constant CHARLIE = 0x3333333333333333333333333333333333333333;
    address constant FEE_RECIPIENT = 0x4444444444444444444444444444444444444444;
    
    Currency constant TOKEN0 = Currency.wrap(0x5555555555555555555555555555555555555555);
    Currency constant TOKEN1 = Currency.wrap(0x6666666666666666666666666666666666666666);
    
    PoolKey public poolKey;
    PoolId public poolId;

    /*//////////////////////////////////////////////////////////////
                            SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy mock contracts
        poolManager = new MockPoolManager();
        avsDirectory = new MockAVSDirectory();
        priceOracle = new MockPriceOracle();
        crossChainMonitor = new MockCrossChainPriceMonitor();
        privateAuctionManager = new MockPrivateAuctionManager();
        
        // Create test pool key
        poolKey = PoolKey({
            currency0: TOKEN0,
            currency1: TOKEN1,
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(0)) // Will be set after hook deployment
        });
        poolId = poolKey.toId();
        
        // Set up test data
        priceOracle.setPrice(TOKEN0, TOKEN1, 3000e18);
        crossChainMonitor.setBestPrice(TOKEN0, TOKEN1, 3000e18);
        privateAuctionManager.authorizeOperator(address(this), true);
        
        // Fund test accounts
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CHARLIE, 100 ether);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function deployHookWithValidAddress() internal returns (EigenLVR_V2) {
        return deployHookWithValidAddress(50); // Default threshold
    }

    function deployHookWithValidAddress(uint256 lvrThreshold) internal returns (EigenLVR_V2) {
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | 
            Hooks.AFTER_SWAP_FLAG | 
            Hooks.BEFORE_ADD_LIQUIDITY_FLAG |
            Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG |
            Hooks.AFTER_INITIALIZE_FLAG
        );
        
        bytes memory constructorArgs = abi.encode(
            IPoolManager(address(poolManager)),
            IAVSDirectory(address(avsDirectory)),
            IPriceOracle(address(priceOracle)),
            address(crossChainMonitor),
            address(privateAuctionManager),
            FEE_RECIPIENT,
            lvrThreshold
        );
        
        bytes memory creationCode = type(EigenLVR_V2).creationCode;
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            flags,
            creationCode,
            constructorArgs
        );
        
        // Deploy using CREATE2
        bytes memory bytecode = abi.encodePacked(creationCode, constructorArgs);
        address payable deployedHook;
        assembly {
            deployedHook := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        return EigenLVR_V2(deployedHook);
    }
}

/*//////////////////////////////////////////////////////////////
                        MOCK CONTRACTS
//////////////////////////////////////////////////////////////*/

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
    
    // Helper functions to call hook functions for testing
    function callAfterInitialize(PoolKey calldata key, uint160 sqrtPriceX96, int24 tick) external {
        IHooks hook = key.hooks;
        if (address(hook) != address(0)) {
            hook.afterInitialize(address(this), key, sqrtPriceX96, tick);
        }
    }
    
    function callBeforeAddLiquidity(address caller, PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData) external returns (bytes4) {
        IHooks hook = key.hooks;
        if (address(hook) != address(0)) {
            return hook.beforeAddLiquidity(caller, key, params, hookData);
        }
        return bytes4(0);
    }
    
    function callBeforeRemoveLiquidity(address caller, PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData) external returns (bytes4) {
        IHooks hook = key.hooks;
        if (address(hook) != address(0)) {
            return hook.beforeRemoveLiquidity(caller, key, params, hookData);
        }
        return bytes4(0);
    }
    
    function callBeforeSwap(address caller, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData) external returns (bytes4, uint128) {
        IHooks hook = key.hooks;
        if (address(hook) != address(0)) {
            (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = hook.beforeSwap(caller, key, params, hookData);
            int256 deltaValue = BeforeSwapDelta.unwrap(delta);
            return (selector, deltaValue >= 0 ? uint128(uint256(deltaValue)) : 0);
        }
        return (bytes4(0), 0);
    }
    
    function callAfterSwap(address caller, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata hookData) external returns (bytes4, int128) {
        IHooks hook = key.hooks;
        if (address(hook) != address(0)) {
            return hook.afterSwap(caller, key, params, delta, hookData);
        }
        return (bytes4(0), 0);
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
        return 1000 ether;
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
        return prices[key] > 0 ? prices[key] : 3000e18; // Default $3000
    }
    
    function getPriceWithTimestamp(Currency token0, Currency token1) external view returns (uint256, uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return (prices[key] > 0 ? prices[key] : 3000e18, timestamps[key]);
    }
    
    function isPriceFresh(Currency, Currency, uint256) external pure returns (bool) {
        return true;
    }
    
    function getPriceConfidence(Currency, Currency) external pure returns (uint256) {
        return 10000;
    }
}

contract MockCrossChainPriceMonitor {
    mapping(bytes32 => uint256) public crossChainPrices;
    mapping(address => bool) public authorizedUpdaters;
    
    function setBestPrice(Currency token0, Currency token1, uint256 price) external {
        bytes32 key = keccak256(abi.encode(token0, token1));
        crossChainPrices[key] = price;
    }
    
    function getBestPrice(Currency token0, Currency token1) external view returns (uint256) {
        bytes32 key = keccak256(abi.encode(token0, token1));
        return crossChainPrices[key] > 0 ? crossChainPrices[key] : 3000e18;
    }
    
    function setAuthorizedUpdater(address updater, bool authorized) external {
        authorizedUpdaters[updater] = authorized;
    }
}

contract MockPrivateAuctionManager {
    mapping(bytes32 => bool) public privateAuctions;
    mapping(address => bool) public authorizedOperators;
    
    function createPrivateAuctionFromEuint(
        bytes32 auctionId,
        uint128, // encryptedMinBid
        uint128, // encryptedReserve
        uint64   // encryptedDuration
    ) external {
        privateAuctions[auctionId] = true;
    }
    
    function authorizeOperator(address operator, bool authorized) external {
        authorizedOperators[operator] = authorized;
    }
}
