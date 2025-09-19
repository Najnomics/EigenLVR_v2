"use strict";
// @notice Logs ABI-encoded function data that can be relayed from HubPool to OptimismSpokePool to set it up.
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("../utils/utils");
const constants_1 = require("../utils/constants");
const customOptimismTokenBridges = {
    // DAI
    "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1": "0x467194771dAe2967Aef3ECbEDD3Bf9a310C76C65",
};
async function main() {
    const [signer] = await utils_1.ethers.getSigners();
    const spokePool = await (0, utils_1.getContractFactory)("Ovm_SpokePool", { signer });
    const hubPool = await (0, utils_1.getContractFactory)("HubPool", { signer });
    // We need to whitelist all L2 --> L1 token mappings
    // We'll use this to store all the call data we need to pass to HubPool#multicall.
    const callData = [];
    for (const l2Token of Object.keys(customOptimismTokenBridges)) {
        // Setup Optimism: We need to call setTokenBridge on Optimism SpokePool so that SpokePool
        // is aware of L2 custom bridge mappings.
        const bridge = customOptimismTokenBridges[l2Token];
        const _callData = spokePool.interface.encodeFunctionData("setTokenBridge", [l2Token, bridge]);
        console.log(`Setting token bridge for ${l2Token} on Optimism SpokePool: ${_callData}`);
        const relayRootCallData = hubPool.interface.encodeFunctionData("relaySpokePoolAdminFunction", [
            constants_1.CHAIN_IDs.OPTIMISM,
            _callData,
        ]);
        callData.push(relayRootCallData);
    }
    const multicallData = hubPool.interface.encodeFunctionData("multicall", [callData]);
    console.log("Data to pass to HubPool#multicall()", multicallData);
}
main().then(() => process.exit(0), (error) => {
    console.log(error);
    process.exit(1);
});
