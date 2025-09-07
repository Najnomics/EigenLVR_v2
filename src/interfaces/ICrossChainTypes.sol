// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ICrossChainTypes
 * @notice Shared types for cross-chain functionality
 */
interface ICrossChainTypes {
    struct CrossChainLVROpportunity {
        uint256 sourceChain;
        uint256 targetChain;
        uint256 profitBps;
        uint256 volume;
        bool isActive;
    }
}