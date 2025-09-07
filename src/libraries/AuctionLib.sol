// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

/**
 * @title AuctionLib
 * @notice Library for auction data structures and utilities
 * @dev Based on original EigenLVR auction system
 */
library AuctionLib {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    struct Auction {
        PoolId poolId;
        uint256 startTime;
        uint256 duration;
        bool isActive;
        bool isComplete;
        address winner;
        uint256 winningBid;
        uint256 totalBids;
    }
    
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
        bool isValid;
    }
    
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    
    uint256 internal constant MIN_AUCTION_DURATION = 5; // 5 seconds
    uint256 internal constant MAX_AUCTION_DURATION = 60; // 60 seconds
    
    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Check if auction is still active
     * @param auction The auction to check
     * @return Whether auction is active
     */
    function isActive(Auction memory auction) internal view returns (bool) {
        return auction.isActive && 
               !auction.isComplete && 
               block.timestamp < auction.startTime + auction.duration;
    }
    
    /**
     * @notice Check if auction has ended
     * @param auction The auction to check
     * @return Whether auction has ended
     */
    function hasEnded(Auction memory auction) internal view returns (bool) {
        return block.timestamp >= auction.startTime + auction.duration;
    }
    
    /**
     * @notice Get remaining time for auction
     * @param auction The auction to check
     * @return remainingTime Time left in seconds
     */
    function getRemainingTime(Auction memory auction) internal view returns (uint256 remainingTime) {
        if (hasEnded(auction)) {
            return 0;
        }
        return (auction.startTime + auction.duration) - block.timestamp;
    }
    
    /**
     * @notice Validate auction parameters
     * @param duration Auction duration in seconds
     * @return isValid Whether parameters are valid
     */
    function validateAuctionParams(uint256 duration) internal pure returns (bool isValid) {
        return duration >= MIN_AUCTION_DURATION && duration <= MAX_AUCTION_DURATION;
    }
    
    /**
     * @notice Calculate auction progress percentage
     * @param auction The auction to analyze
     * @return progress Progress as percentage (0-100)
     */
    function getAuctionProgress(Auction memory auction) internal view returns (uint256 progress) {
        if (!auction.isActive) return 100;
        if (block.timestamp < auction.startTime) return 0;
        
        uint256 elapsed = block.timestamp - auction.startTime;
        if (elapsed >= auction.duration) return 100;
        
        return (elapsed * 100) / auction.duration;
    }
}