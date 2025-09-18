// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {CrossChainPriceMonitor} from "../../src/crosschain/CrossChainPriceMonitor.sol";
import {PrivateAuctionManager} from "../../src/privacy/PrivateAuctionManager.sol";

contract ContractDeploymentTest is Test {
    
    function testDeployCrossChainPriceMonitor() public {
        CrossChainPriceMonitor monitor = new CrossChainPriceMonitor();
        assertTrue(address(monitor) != address(0));
        console2.log("CrossChainPriceMonitor deployed at:", address(monitor));
    }
    
    function testDeployPrivateAuctionManager() public {
        PrivateAuctionManager manager = new PrivateAuctionManager();
        assertTrue(address(manager) != address(0));
        console2.log("PrivateAuctionManager deployed at:", address(manager));
    }
}

