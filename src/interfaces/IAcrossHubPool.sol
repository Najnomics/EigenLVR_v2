// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IAcrossHubPool
 * @notice Interface for Across Protocol Hub Pool for cross-chain bridging
 * @dev Simplified interface based on Across Protocol v3
 */
interface IAcrossHubPool {
    /**
     * @notice Deposit tokens for cross-chain bridging via Across Protocol
     * @param depositor Address initiating the deposit
     * @param recipient Address to receive tokens on destination chain
     * @param inputToken Token being deposited
     * @param outputToken Token to receive on destination chain
     * @param inputAmount Amount being deposited
     * @param outputAmount Minimum amount to receive
     * @param destinationChainId Target chain ID
     * @param exclusiveRelayer Optional exclusive relayer address
     * @param quoteTimestamp Quote timestamp
     * @param fillDeadline Deadline for fill
     * @param exclusivityDeadline Exclusivity deadline
     * @param message Additional bridge message data
     */
    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;
    
    /**
     * @notice Get the current fee for a cross-chain transfer
     * @param inputToken Token being deposited
     * @param outputToken Token to receive
     * @param inputAmount Amount being transferred
     * @param destinationChainId Target chain ID
     * @return fee The bridge fee
     */
    function getBridgeFee(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 destinationChainId
    ) external view returns (uint256 fee);
}