"use strict";
// @notice Prints bytes input you'll need to send ETH from L2 aliased HubPool address to l2 recipient address via
// Arbitrum_RescueAdapter.
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("../utils/utils");
async function main() {
    const amountOfEth = (0, utils_1.toWei)("2.9");
    const message = utils_1.defaultAbiCoder.encode(["uint256"], [amountOfEth]);
    console.log(`Message to include in call to relaySpokePoolAdminFunction: `, message);
}
main().then(() => process.exit(0), (error) => {
    console.log(error);
    process.exit(1);
});
