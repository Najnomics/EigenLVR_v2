"use strict";
// @notice Logs ABI-encoded function data that can be relayed from HubPool to ArbitrumSpokePool to set it up.
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("../utils/utils");
const constants_1 = require("../utils/constants");
async function main() {
    const [signer] = await utils_1.ethers.getSigners();
    const spokePool = await (0, utils_1.getContractFactory)("Arbitrum_SpokePool", { signer });
    const hubPool = await (0, utils_1.getContractFactory)("HubPool", { signer });
    // We need to whitelist all L2 --> L1 token mappings
    // We'll use this to store all the call data we need to pass to HubPool#multicall.
    const callData = [];
    const tokenSymbols = Object.values(constants_1.TOKEN_SYMBOLS_MAP);
    for (const token of tokenSymbols) {
        // Setup Arbitrum: We need to call whitelistToken on Arbitrum SpokePool so that SpokePool
        // is aware of L1 to L2 mappings.
        const l1Token = token.addresses[constants_1.CHAIN_IDs.MAINNET];
        const arbitrumToken = token.addresses[constants_1.CHAIN_IDs.ARBITRUM];
        if (!l1Token || !arbitrumToken) {
            console.log(`Token ${token.symbol} does not exist on both Arbitrum and Mainnet. Skipping...`);
            continue;
        }
        const _callData = spokePool.interface.encodeFunctionData("whitelistToken", [arbitrumToken, l1Token]);
        console.log(`Whitelisting mapping for ${token.symbol} on Arbitrum SpokePool: ${_callData}`);
        const relayRootCallData = hubPool.interface.encodeFunctionData("relaySpokePoolAdminFunction", [
            constants_1.CHAIN_IDs.ARBITRUM,
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
