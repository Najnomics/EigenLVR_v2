// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ChainRegistry
 * @author EigenLVR Team
 * @notice Registry for supported chains and their configuration
 * @dev Manages chain metadata, oracle addresses, and bridge configurations
 */
contract ChainRegistry is Ownable {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    struct ChainConfig {
        uint256 chainId;
        string name;
        address oracle;
        address bridge;
        uint256 confirmationBlocks;
        uint256 averageBlockTime;
        bool isActive;
        uint256 maxSlippage; // in basis points
    }
    
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Chain configurations
    mapping(uint256 => ChainConfig) public chains;
    
    /// @notice Supported chain list
    uint256[] public supportedChainIds;
    
    /// @notice Chain ID to index mapping
    mapping(uint256 => uint256) public chainIndexes;
    
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event ChainAdded(uint256 indexed chainId, string name, address oracle);
    event ChainUpdated(uint256 indexed chainId, string name);
    event ChainStatusChanged(uint256 indexed chainId, bool isActive);
    
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor() Ownable(msg.sender) {
        _addChain(1, "Ethereum", address(0x1), address(0x2), 12, 13, 100); // 1% max slippage
        _addChain(42161, "Arbitrum", address(0x3), address(0x4), 1, 1, 50); // 0.5% max slippage
        _addChain(10, "Optimism", address(0x5), address(0x6), 1, 2, 50);
        _addChain(137, "Polygon", address(0x7), address(0x8), 128, 2, 100);
        _addChain(8453, "Base", address(0x9), address(0xa), 1, 2, 50);
    }
    
    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Add a new supported chain
     */
    function addChain(
        uint256 chainId,
        string calldata name,
        address oracle,
        address bridge,
        uint256 confirmationBlocks,
        uint256 averageBlockTime,
        uint256 maxSlippage
    ) external onlyOwner {
        require(chains[chainId].chainId == 0, "Chain already exists");
        _addChain(chainId, name, oracle, bridge, confirmationBlocks, averageBlockTime, maxSlippage);
    }
    
    /**
     * @notice Update chain configuration
     */
    function updateChain(
        uint256 chainId,
        string calldata name,
        address oracle,
        address bridge,
        uint256 confirmationBlocks,
        uint256 averageBlockTime,
        uint256 maxSlippage
    ) external onlyOwner {
        require(chains[chainId].chainId != 0, "Chain does not exist");
        
        chains[chainId].name = name;
        chains[chainId].oracle = oracle;
        chains[chainId].bridge = bridge;
        chains[chainId].confirmationBlocks = confirmationBlocks;
        chains[chainId].averageBlockTime = averageBlockTime;
        chains[chainId].maxSlippage = maxSlippage;
        
        emit ChainUpdated(chainId, name);
    }
    
    /**
     * @notice Enable or disable a chain
     */
    function setChainStatus(uint256 chainId, bool isActive) external onlyOwner {
        require(chains[chainId].chainId != 0, "Chain does not exist");
        chains[chainId].isActive = isActive;
        emit ChainStatusChanged(chainId, isActive);
    }
    
    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get chain configuration
     */
    function getChainConfig(uint256 chainId) external view returns (ChainConfig memory) {
        return chains[chainId];
    }
    
    /**
     * @notice Check if chain is supported and active
     */
    function isChainSupported(uint256 chainId) external view returns (bool) {
        return chains[chainId].chainId != 0 && chains[chainId].isActive;
    }
    
    /**
     * @notice Get all supported chains
     */
    function getSupportedChains() external view returns (uint256[] memory) {
        uint256[] memory activeChains = new uint256[](supportedChainIds.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < supportedChainIds.length; i++) {
            uint256 chainId = supportedChainIds[i];
            if (chains[chainId].isActive) {
                activeChains[count] = chainId;
                count++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = activeChains[i];
        }
        
        return result;
    }
    
    /**
     * @notice Get oracle address for a chain
     */
    function getChainOracle(uint256 chainId) external view returns (address) {
        return chains[chainId].oracle;
    }
    
    /**
     * @notice Get bridge address for a chain
     */
    function getChainBridge(uint256 chainId) external view returns (address) {
        return chains[chainId].bridge;
    }
    
    /**
     * @notice Calculate estimated confirmation time for a chain
     */
    function getConfirmationTime(uint256 chainId) external view returns (uint256) {
        ChainConfig memory config = chains[chainId];
        return config.confirmationBlocks * config.averageBlockTime;
    }
    
    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function _addChain(
        uint256 chainId,
        string memory name,
        address oracle,
        address bridge,
        uint256 confirmationBlocks,
        uint256 averageBlockTime,
        uint256 maxSlippage
    ) internal {
        chains[chainId] = ChainConfig({
            chainId: chainId,
            name: name,
            oracle: oracle,
            bridge: bridge,
            confirmationBlocks: confirmationBlocks,
            averageBlockTime: averageBlockTime,
            isActive: true,
            maxSlippage: maxSlippage
        });
        
        chainIndexes[chainId] = supportedChainIds.length;
        supportedChainIds.push(chainId);
        
        emit ChainAdded(chainId, name, oracle);
    }
}