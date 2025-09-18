// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

/**
 * @title HookMiner
 * @notice Utility to find valid hook addresses with required permissions
 */
library HookMiner {
    uint160 constant FLAG_MASK = 0x3FFF; // bottom 14 bits

    /**
     * @notice Find a salt that will deploy a hook to a valid address
     * @param deployer The address that will deploy the hook
     * @param flags The required hook permission flags  
     * @param creationCode The contract creation code
     * @param constructorArgs The encoded constructor arguments
     * @return hookAddress The computed valid hook address
     * @return salt The salt to use for CREATE2 deployment
     */
    function find(
        address deployer,
        uint160 flags,
        bytes memory creationCode,
        bytes memory constructorArgs
    ) internal pure returns (address hookAddress, bytes32 salt) {
        bytes memory bytecode = abi.encodePacked(creationCode, constructorArgs);
        
        for (uint256 i = 0; i < 1000000; i++) {
            salt = bytes32(i);
            hookAddress = computeAddress(deployer, salt, bytecode);
            
            if (uint160(hookAddress) & FLAG_MASK == flags) {
                return (hookAddress, salt);
            }
        }
        
        revert("HookMiner: Could not find valid address");
    }

    /**
     * @notice Compute the CREATE2 address
     */
    function computeAddress(
        address deployer,
        bytes32 salt,
        bytes memory bytecode
    ) internal pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                deployer,
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }
}