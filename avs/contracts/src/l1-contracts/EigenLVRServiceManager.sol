// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAVSDirectory} from "../../../interfaces/IAVSDirectory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title EigenLVRServiceManager
 * @notice EigenLayer L1 service manager for EigenLVR V2 AVS
 * @dev This is a CONNECTOR contract that manages EigenLayer integration only.
 * The actual LVR auction business logic remains in the main EigenLVR_V2 contract.
 * This contract handles:
 * - Operator registration with EigenLayer
 * - Staking management
 * - Task validation (delegates to L2 hook for actual auction logic)
 */
contract EigenLVRServiceManager is Ownable, ReentrancyGuard {
    
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Address of the main EigenLVR V2 Hook contract on L2
    address public immutable eigenLVRHookL2;
    
    /// @notice Address of the AVS Directory
    IAVSDirectory public immutable avsDirectory;
    
    /// @notice Minimum stake required for EigenLVR operators
    uint256 public constant MINIMUM_EIGENLVR_STAKE = 10 ether;
    
    /// @notice Mapping of registered operators
    mapping(address => bool) public registeredOperators;
    
    /// @notice Mapping of operator stakes
    mapping(address => uint256) public operatorStakes;
    
    /// @notice Supported chains for cross-chain operations
    mapping(uint256 => bool) public supportedChains;
    
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event EigenLVROperatorRegistered(address indexed operator, bytes32 indexed operatorId);
    event EigenLVROperatorDeregistered(address indexed operator, bytes32 indexed operatorId);
    event EigenLVRHookUpdated(address indexed oldHook, address indexed newHook);
    event ChainSupportUpdated(uint256 indexed chainId, bool supported);
    
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @dev Constructor for EigenLVR Service Manager
     * @param _avsDirectory The AVS Directory contract address
     * @param _eigenLVRHookL2 The address of the main EigenLVR V2 Hook on L2
     */
    constructor(
        IAVSDirectory _avsDirectory,
        address _eigenLVRHookL2
    ) Ownable(msg.sender) {
        require(address(_avsDirectory) != address(0), "Invalid AVS Directory");
        require(_eigenLVRHookL2 != address(0), "Invalid L2 hook address");
        
        avsDirectory = _avsDirectory;
        eigenLVRHookL2 = _eigenLVRHookL2;
        
        // Initialize supported chains
        _initializeSupportedChains();
    }

    /*//////////////////////////////////////////////////////////////
                              INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @dev Initialize supported chains
     */
    function _initializeSupportedChains() internal {
        supportedChains[1] = true;     // Ethereum
        supportedChains[42161] = true; // Arbitrum
        supportedChains[10] = true;    // Optimism
        supportedChains[137] = true;   // Polygon
        supportedChains[8453] = true;  // Base
    }

    /*//////////////////////////////////////////////////////////////
                         EIGENLVR-SPECIFIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Register an operator specifically for EigenLVR tasks
     * @dev This extends the base registration with EigenLVR-specific requirements
     * @param operator The operator address to register
     * @param operatorSignature The operator's signature for EigenLayer
     */
    function registerEigenLVROperator(
        address operator,
        bytes calldata operatorSignature
    ) external payable nonReentrant {
        require(msg.value >= MINIMUM_EIGENLVR_STAKE, "Insufficient stake for EigenLVR operations");
        require(!registeredOperators[operator], "Operator already registered");
        
        // Register with EigenLayer AVS Directory
        avsDirectory.registerOperatorToAVS(operator, operatorSignature);
        
        // Update local state
        registeredOperators[operator] = true;
        operatorStakes[operator] = msg.value;
        
        bytes32 operatorId = keccak256(abi.encodePacked(operator, block.timestamp));
        emit EigenLVROperatorRegistered(operator, operatorId);
    }

    /**
     * @notice Deregister an operator from EigenLVR tasks
     * @param operator The operator address to deregister
     */
    function deregisterEigenLVROperator(address operator) external nonReentrant {
        require(registeredOperators[operator], "Operator not registered");
        
        // Deregister from EigenLayer AVS Directory
        avsDirectory.deregisterOperatorFromAVS(operator);
        
        // Update local state
        registeredOperators[operator] = false;
        operatorStakes[operator] = 0;
        
        bytes32 operatorId = keccak256(abi.encodePacked(operator, block.timestamp));
        emit EigenLVROperatorDeregistered(operator, operatorId);
    }

    /**
     * @notice Check if an operator meets EigenLVR requirements
     * @param operator The operator address to check
     * @return Whether the operator is qualified for EigenLVR tasks
     */
    function isEigenLVROperatorQualified(address operator) external view returns (bool) {
        return registeredOperators[operator] && operatorStakes[operator] >= MINIMUM_EIGENLVR_STAKE;
    }

    /**
     * @notice Get the L2 EigenLVR Hook contract address
     * @return The address of the main EigenLVR logic contract
     */
    function getEigenLVRHook() external view returns (address) {
        return eigenLVRHookL2;
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Internal function to check operator registration
     * @param operator The operator address
     * @return Whether the operator is registered
     */
    function _isRegistered(address operator) internal view returns (bool) {
        return registeredOperators[operator];
    }

    /**
     * @notice Internal function to get operator stake
     * @param operator The operator address
     * @return The operator's stake amount
     */
    function _getOperatorStake(address operator) internal view returns (uint256) {
        return operatorStakes[operator];
    }
    
    /**
     * @notice Check if a chain is supported for cross-chain operations
     * @param chainId The chain ID to check
     * @return Whether the chain is supported
     */
    function isChainSupported(uint256 chainId) external view returns (bool) {
        return supportedChains[chainId];
    }
    
    /**
     * @notice Get all supported chain IDs
     * @return Array of supported chain IDs
     */
    function getSupportedChains() external pure returns (uint256[] memory) {
        uint256[] memory chains = new uint256[](5);
        chains[0] = 1;     // Ethereum
        chains[1] = 42161; // Arbitrum
        chains[2] = 10;    // Optimism
        chains[3] = 137;   // Polygon
        chains[4] = 8453;  // Base
        return chains;
    }
    
    /**
     * @notice Update chain support (only owner)
     * @param chainId The chain ID to update
     * @param supported Whether the chain is supported
     */
    function updateChainSupport(uint256 chainId, bool supported) external onlyOwner {
        supportedChains[chainId] = supported;
        emit ChainSupportUpdated(chainId, supported);
    }
    
    /**
     * @notice Withdraw operator stake (only owner)
     * @param operator The operator address
     * @param amount The amount to withdraw
     */
    function withdrawOperatorStake(address operator, uint256 amount) external onlyOwner {
        require(operatorStakes[operator] >= amount, "Insufficient stake");
        operatorStakes[operator] -= amount;
        
        (bool success, ) = payable(operator).call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}