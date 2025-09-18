// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICrossChainTypes} from "../interfaces/ICrossChainTypes.sol";

/**
 * @title CrossChainLVRDetector
 * @author EigenLVR Team
 * @notice Multi-chain price monitoring and arbitrage detection system
 * @dev Detects profitable cross-chain LVR opportunities across supported L2s
 */
contract CrossChainLVRDetector is Ownable {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    
    uint256 public constant MIN_PROFIT_THRESHOLD = 50; // 0.5% minimum profit
    uint256 public constant BASIS_POINTS = 10000;
    
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    // Use shared CrossChainLVROpportunity from ICrossChainTypes
    
    struct ChainPriceData {
        uint256 price;
        uint256 timestamp;
        uint256 confidence;
        bool isValid;
    }
    
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Supported chains for cross-chain arbitrage
    mapping(uint256 => bool) public supportedChains;
    
    /// @notice Chain price feeds: chain => token pair => price data
    mapping(uint256 => mapping(bytes32 => ChainPriceData)) public chainPrices;
    
    /// @notice Bridge cost estimates: source => target => cost in basis points
    mapping(uint256 => mapping(uint256 => uint256)) public bridgeCosts;
    
    /// @notice Available liquidity per chain: chain => token => liquidity
    mapping(uint256 => mapping(address => uint256)) public chainLiquidity;
    
    /// @notice Authorized price updaters
    mapping(address => bool) public authorizedUpdaters;
    
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event CrossChainOpportunityDetected(
        uint256 indexed sourceChain,
        uint256 indexed targetChain,
        uint256 profitBps,
        uint256 volume
    );
    
    event PriceUpdated(
        uint256 indexed chainId,
        bytes32 indexed tokenPair,
        uint256 price,
        uint256 confidence
    );
    
    event ChainSupported(uint256 indexed chainId, bool supported);
    
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyAuthorizedUpdater() {
        require(authorizedUpdaters[msg.sender], "CrossChainDetector: unauthorized");
        _;
    }
    
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor() Ownable(msg.sender) {
        // Initialize with major L2s
        _addSupportedChain(1); // Ethereum
        _addSupportedChain(42161); // Arbitrum
        _addSupportedChain(10); // Optimism
        _addSupportedChain(137); // Polygon
        _addSupportedChain(8453); // Base
        
        // Initialize bridge costs (in basis points)
        _setBridgeCost(1, 42161, 5); // ETH -> ARB: 0.05%
        _setBridgeCost(1, 10, 5);    // ETH -> OP: 0.05%
        _setBridgeCost(1, 137, 10);  // ETH -> POLY: 0.1%
        _setBridgeCost(1, 8453, 5);  // ETH -> BASE: 0.05%
    }
    
    /*//////////////////////////////////////////////////////////////
                        CROSS-CHAIN DETECTION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Detect cross-chain LVR opportunities for a given swap
     * @param key Pool key containing token pair information
     * @param params Swap parameters
     * @return hasOpportunity Whether a profitable opportunity exists
     * @return opportunity The detected opportunity details
     */
    function detectCrossChainOpportunity(
        PoolKey calldata key,
        SwapParams calldata params
    ) external view returns (bool, ICrossChainTypes.CrossChainLVROpportunity memory) {
        bytes32 tokenPair = _getTokenPairHash(key);
        uint256 currentChain = block.chainid;
        
        ICrossChainTypes.CrossChainLVROpportunity memory bestOpportunity;
        bool foundOpportunity = false;
        
        // Check all supported chains for arbitrage opportunities
        for (uint256 i = 1; i <= 8453; i++) {
            if (!supportedChains[i] || i == currentChain) continue;
            
            ICrossChainTypes.CrossChainLVROpportunity memory opp = _analyzeChainPair(
                currentChain,
                i,
                tokenPair,
                uint256(params.amountSpecified)
            );
            
            if (opp.isActive && opp.profitBps > bestOpportunity.profitBps) {
                bestOpportunity = opp;
                foundOpportunity = true;
            }
        }
        
        return (foundOpportunity, bestOpportunity);
    }
    
    /**
     * @notice Analyze arbitrage opportunity between two chains
     */
    function _analyzeChainPair(
        uint256 sourceChain,
        uint256 targetChain,
        bytes32 tokenPair,
        uint256 volume
    ) internal view returns (ICrossChainTypes.CrossChainLVROpportunity memory) {
        ChainPriceData memory sourcePrice = chainPrices[sourceChain][tokenPair];
        ChainPriceData memory targetPrice = chainPrices[targetChain][tokenPair];
        
        // Validate price data
        if (!sourcePrice.isValid || !targetPrice.isValid) {
            return ICrossChainTypes.CrossChainLVROpportunity(sourceChain, targetChain, 0, 0, false);
        }
        
        // Calculate price difference
        uint256 priceDiff;
        if (sourcePrice.price > targetPrice.price) {
            priceDiff = ((sourcePrice.price - targetPrice.price) * BASIS_POINTS) / targetPrice.price;
        } else {
            priceDiff = ((targetPrice.price - sourcePrice.price) * BASIS_POINTS) / sourcePrice.price;
        }
        
        // Subtract bridge costs
        uint256 bridgeCost = bridgeCosts[sourceChain][targetChain];
        uint256 netProfit = priceDiff > bridgeCost ? priceDiff - bridgeCost : 0;
        
        // Check if profitable and sufficient liquidity exists
        bool isActive = netProfit >= MIN_PROFIT_THRESHOLD && 
                       _hasSufficientLiquidity(targetChain, tokenPair, volume);
        
        return ICrossChainTypes.CrossChainLVROpportunity({
            sourceChain: sourceChain,
            targetChain: targetChain,
            profitBps: netProfit,
            volume: volume,
            isActive: isActive
        });
    }
    
    /*//////////////////////////////////////////////////////////////
                            PRICE MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Update price for a token pair on a specific chain
     */
    function updateChainPrice(
        uint256 chainId,
        bytes32 tokenPair,
        uint256 price,
        uint256 confidence
    ) external onlyAuthorizedUpdater {
        require(supportedChains[chainId], "CrossChainDetector: unsupported chain");
        require(confidence <= BASIS_POINTS, "CrossChainDetector: invalid confidence");
        
        chainPrices[chainId][tokenPair] = ChainPriceData({
            price: price,
            timestamp: block.timestamp,
            confidence: confidence,
            isValid: true
        });
        
        emit PriceUpdated(chainId, tokenPair, price, confidence);
    }
    
    /**
     * @notice Batch update prices for multiple chains
     */
    function batchUpdatePrices(
        uint256[] calldata chainIds,
        bytes32[] calldata tokenPairs,
        uint256[] calldata prices,
        uint256[] calldata confidences
    ) external onlyAuthorizedUpdater {
        require(
            chainIds.length == tokenPairs.length &&
            tokenPairs.length == prices.length &&
            prices.length == confidences.length,
            "CrossChainDetector: array length mismatch"
        );
        
        for (uint256 i = 0; i < chainIds.length; i++) {
            chainPrices[chainIds[i]][tokenPairs[i]] = ChainPriceData({
                price: prices[i],
                timestamp: block.timestamp,
                confidence: confidences[i],
                isValid: true
            });
            
            emit PriceUpdated(chainIds[i], tokenPairs[i], prices[i], confidences[i]);
        }
    }
    
    /*//////////////////////////////////////////////////////////////
                            LIQUIDITY TRACKING
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Update available liquidity for a token on a chain
     */
    function updateChainLiquidity(
        uint256 chainId,
        address token,
        uint256 liquidity
    ) external onlyAuthorizedUpdater {
        chainLiquidity[chainId][token] = liquidity;
    }
    
    /**
     * @notice Check if sufficient liquidity exists for arbitrage
     */
    function _hasSufficientLiquidity(
        uint256 /* chainId */,
        bytes32 /* tokenPair */,
        uint256 /* requiredVolume */
    ) internal pure returns (bool) {
        // Simplified check - in production would parse token addresses from pair hash
        // and check actual liquidity for both tokens
        return true; // Placeholder implementation
    }
    
    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Add or remove supported chain
     */
    function setSupportedChain(uint256 chainId, bool supported) external onlyOwner {
        supportedChains[chainId] = supported;
        emit ChainSupported(chainId, supported);
    }
    
    /**
     * @notice Set bridge cost between two chains
     */
    function setBridgeCost(
        uint256 sourceChain,
        uint256 targetChain,
        uint256 costBps
    ) external onlyOwner {
        require(costBps <= 1000, "CrossChainDetector: cost too high"); // Max 10%
        bridgeCosts[sourceChain][targetChain] = costBps;
    }
    
    /**
     * @notice Authorize price updater
     */
    function setAuthorizedUpdater(address updater, bool authorized) external onlyOwner {
        authorizedUpdaters[updater] = authorized;
    }
    
    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function _addSupportedChain(uint256 chainId) internal {
        supportedChains[chainId] = true;
        emit ChainSupported(chainId, true);
    }
    
    function _setBridgeCost(uint256 source, uint256 target, uint256 cost) internal {
        bridgeCosts[source][target] = cost;
    }
    
    function _getTokenPairHash(PoolKey calldata key) internal pure returns (bytes32) {
        return keccak256(abi.encode(key.currency0, key.currency1));
    }
    
    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get current price for a token pair on a chain
     */
    function getChainPrice(
        uint256 chainId,
        bytes32 tokenPair
    ) external view returns (ChainPriceData memory) {
        return chainPrices[chainId][tokenPair];
    }
    
    /**
     * @notice Check if price data is fresh (within last 5 minutes)
     */
    function isPriceFresh(
        uint256 chainId,
        bytes32 tokenPair
    ) external view returns (bool) {
        ChainPriceData memory priceData = chainPrices[chainId][tokenPair];
        return priceData.isValid && (block.timestamp - priceData.timestamp) <= 300;
    }
    
    /**
     * @notice Get all supported chain IDs
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
}