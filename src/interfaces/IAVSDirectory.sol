// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IAVSDirectory
 * @notice Interface for EigenLayer AVS Directory
 * @dev Interface for AVS registration and operator management
 */
interface IAVSDirectory {
    /**
     * @notice Register as an AVS
     * @param operatorSignature Signature from operator
     */
    function registerOperatorToAVS(
        address operator,
        bytes calldata operatorSignature
    ) external;
    
    /**
     * @notice Deregister operator from AVS
     * @param operator Address of operator to deregister
     */
    function deregisterOperatorFromAVS(address operator) external;
    
    /**
     * @notice Check if operator is registered to AVS
     * @param avs AVS address
     * @param operator Operator address
     * @return Whether operator is registered
     */
    function isOperatorRegistered(address avs, address operator) external view returns (bool);
    
    /**
     * @notice Get operator stake for AVS
     * @param avs AVS address
     * @param operator Operator address
     * @return stake Operator's stake amount
     */
    function getOperatorStake(address avs, address operator) external view returns (uint256 stake);
}