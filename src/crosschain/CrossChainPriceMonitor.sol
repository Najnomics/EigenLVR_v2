// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CrossChainPriceMonitor
 * @notice Simplified cross-chain price monitoring for enhanced LVR detection
 * @dev Aggregates price data from multiple chains for better arbitrage detection
 */
contract CrossChainPriceMonitor is Ownable {
    
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    struct PriceData {
        uint256 price;
        uint256 timestamp;
        uint256 confidence;
        bool isValid;
    }
    
    struct ChainInfo {
        uint256 chainId;
        string name;
        bool isActive;
        uint256 weight; // For weighted price calculation
    }
    
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Chain configurations
    mapping(uint256 => ChainInfo) public chains;
    uint256[] public supportedChainIds;
    
    /// @notice Price data: chainId => tokenPair => price data
    mapping(uint256 => mapping(bytes32 => PriceData)) public prices;
    
    /// @notice Authorized price updaters
    mapping(address => bool) public authorizedUpdaters;
    
    /// @notice Price staleness threshold (5 minutes)
    uint256 public constant STALENESS_THRESHOLD = 300;
    
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event PriceUpdated(uint256 indexed chainId, bytes32 indexed pair, uint256 price, uint256 confidence);
    event ChainAdded(uint256 indexed chainId, string name, uint256 weight);
    event ChainStatusChanged(uint256 indexed chainId, bool isActive);
    
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor() Ownable(msg.sender) {
        // Initialize with major chains
        _addChain(1, "Ethereum", 100, true);        // Highest weight
        _addChain(42161, "Arbitrum", 80, true);     
        _addChain(10, "Optimism", 70, true);        
        _addChain(137, "Polygon", 60, true);        
        _addChain(8453, "Base", 75, true);          
    }
    
    /*//////////////////////////////////////////////////////////////
                        PRICE MONITORING
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get best price across all chains
     * @param token0 First token in pair
     * @param token1 Second token in pair
     * @return bestPrice Weighted average of fresh prices
     */
    function getBestPrice(Currency token0, Currency token1) external view returns (uint256 bestPrice) {
        bytes32 pair = _getPairHash(token0, token1);
        
        uint256 totalWeight = 0;
        uint256 weightedSum = 0;
        
        for (uint256 i = 0; i < supportedChainIds.length; i++) {
            uint256 chainId = supportedChainIds[i];
            ChainInfo memory chainInfo = chains[chainId];
            
            if (!chainInfo.isActive) continue;
            
            PriceData memory priceData = prices[chainId][pair];
            
            // Only use fresh prices
            if (priceData.isValid && 
                block.timestamp - priceData.timestamp <= STALENESS_THRESHOLD) {
                
                uint256 effectiveWeight = (chainInfo.weight * priceData.confidence) / 10000;
                weightedSum += priceData.price * effectiveWeight;
                totalWeight += effectiveWeight;
            }
        }
        
        return totalWeight > 0 ? weightedSum / totalWeight : 0;
    }
    
    /**
     * @notice Get price from specific chain
     */
    function getChainPrice(
        uint256 chainId, 
        Currency token0, 
        Currency token1
    ) external view returns (uint256 price, uint256 timestamp, bool isValid) {
        bytes32 pair = _getPairHash(token0, token1);
        PriceData memory data = prices[chainId][pair];
        
        return (data.price, data.timestamp, data.isValid);
    }
    
    /**
     * @notice Check if cross-chain data suggests better pricing
     */
    function hasBetterCrossChainPrice(
        Currency token0,
        Currency token1,
        uint256 localPrice,
        uint256 minImprovementBps
    ) external view returns (bool, uint256 betterPrice) {
        uint256 crossChainPrice = this.getBestPrice(token0, token1);
        
        if (crossChainPrice == 0) return (false, 0);
        
        uint256 improvement = crossChainPrice > localPrice ? 
            ((crossChainPrice - localPrice) * 10000) / localPrice :
            ((localPrice - crossChainPrice) * 10000) / crossChainPrice;
        
        return (improvement >= minImprovementBps, crossChainPrice);
    }
    
    /*//////////////////////////////////////////////////////////////
                        PRICE UPDATES
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Update price for a token pair on specific chain
     */
    function updatePrice(
        uint256 chainId,
        Currency token0,
        Currency token1,
        uint256 price,
        uint256 confidence
    ) external onlyAuthorizedUpdater {
        require(chains[chainId].isActive, "Chain not active");
        require(confidence <= 10000, "Invalid confidence");
        require(price > 0, "Price must be positive");
        
        bytes32 pair = _getPairHash(token0, token1);
        
        prices[chainId][pair] = PriceData({
            price: price,
            timestamp: block.timestamp,
            confidence: confidence,
            isValid: true
        });
        
        emit PriceUpdated(chainId, pair, price, confidence);
    }
    
    /**
     * @notice Batch update prices
     */
    function batchUpdatePrices(
        uint256[] calldata chainIds,
        bytes32[] calldata pairs,
        uint256[] calldata priceValues,
        uint256[] calldata confidences
    ) external onlyAuthorizedUpdater {
        require(
            chainIds.length == pairs.length &&
            pairs.length == priceValues.length &&
            priceValues.length == confidences.length,
            "Array length mismatch"
        );
        
        for (uint256 i = 0; i < chainIds.length; i++) {
            if (chains[chainIds[i]].isActive && priceValues[i] > 0) {
                prices[chainIds[i]][pairs[i]] = PriceData({
                    price: priceValues[i],
                    timestamp: block.timestamp,
                    confidence: confidences[i],
                    isValid: true
                });
                
                emit PriceUpdated(chainIds[i], pairs[i], priceValues[i], confidences[i]);
            }
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Add new chain
     */
    function addChain(
        uint256 chainId,
        string calldata name,
        uint256 weight,
        bool isActive
    ) external onlyOwner {
        require(chains[chainId].chainId == 0, "Chain already exists");
        _addChain(chainId, name, weight, isActive);
    }
    
    /**
     * @notice Update chain configuration
     */
    function updateChain(
        uint256 chainId,
        string calldata name,
        uint256 weight,
        bool isActive
    ) external onlyOwner {
        require(chains[chainId].chainId != 0, "Chain does not exist");
        
        chains[chainId].name = name;
        chains[chainId].weight = weight;
        chains[chainId].isActive = isActive;
        
        emit ChainStatusChanged(chainId, isActive);
    }
    
    /**
     * @notice Authorize price updater
     */
    function setAuthorizedUpdater(address updater, bool authorized) external onlyOwner {
        authorizedUpdaters[updater] = authorized;
    }
    
    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get all supported chains
     */
    function getSupportedChains() external view returns (uint256[] memory activeChains) {
        uint256 count = 0;
        
        // Count active chains
        for (uint256 i = 0; i < supportedChainIds.length; i++) {
            if (chains[supportedChainIds[i]].isActive) {
                count++;
            }
        }
        
        // Build active chains array
        activeChains = new uint256[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < supportedChainIds.length; i++) {
            if (chains[supportedChainIds[i]].isActive) {
                activeChains[index] = supportedChainIds[i];
                index++;
            }
        }
    }
    
    /**
     * @notice Get price freshness status
     */
    function isPriceFresh(
        uint256 chainId,
        Currency token0,
        Currency token1
    ) external view returns (bool fresh) {
        bytes32 pair = _getPairHash(token0, token1);
        PriceData memory data = prices[chainId][pair];
        
        return data.isValid && (block.timestamp - data.timestamp <= STALENESS_THRESHOLD);
    }
    
    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function _addChain(
        uint256 chainId,
        string memory name,
        uint256 weight,
        bool isActive
    ) internal {
        chains[chainId] = ChainInfo({
            chainId: chainId,
            name: name,
            weight: weight,
            isActive: isActive
        });
        
        supportedChainIds.push(chainId);
        emit ChainAdded(chainId, name, weight);
    }
    
    function _getPairHash(Currency token0, Currency token1) internal pure returns (bytes32) {
        return keccak256(abi.encode(token0, token1));
    }
    
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyAuthorizedUpdater() {
        require(authorizedUpdaters[msg.sender], "Not authorized updater");
        _;
    }
}