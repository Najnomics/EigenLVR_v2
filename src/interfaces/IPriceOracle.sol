// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/**
 * @title IPriceOracle
 * @notice Interface for price oracle integration
 * @dev Used for LVR detection and cross-chain price feeds
 */
interface IPriceOracle {
    /**
     * @notice Get the current price for a token pair
     * @param token0 First token in the pair
     * @param token1 Second token in the pair
     * @return price Current price with 18 decimals
     */
    function getPrice(Currency token0, Currency token1) external view returns (uint256 price);
    
    /**
     * @notice Get price with timestamp
     * @param token0 First token
     * @param token1 Second token
     * @return price Current price
     * @return timestamp Last update timestamp
     */
    function getPriceWithTimestamp(
        Currency token0, 
        Currency token1
    ) external view returns (uint256 price, uint256 timestamp);
    
    /**
     * @notice Check if price data is fresh
     * @param token0 First token
     * @param token1 Second token
     * @param maxAge Maximum acceptable age in seconds
     * @return Whether price is fresh
     */
    function isPriceFresh(
        Currency token0,
        Currency token1,
        uint256 maxAge
    ) external view returns (bool);
    
    /**
     * @notice Get price confidence score
     * @param token0 First token
     * @param token1 Second token
     * @return confidence Confidence score (0-10000 basis points)
     */
    function getPriceConfidence(
        Currency token0,
        Currency token1
    ) external view returns (uint256 confidence);
}