"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("../utils/utils");
const utils_hre_1 = require("../utils/utils.hre");
const fs_1 = require("fs");
const path_1 = __importDefault(require("path"));
const cid_1 = require("multiformats/cid");
const sdk_1 = __importDefault(require("@pinata/sdk"));
/**
 * Script to upload metadata JSON file to IPFS via Pinata and set token uri. Make sure to set the env var
 * `PINATA_JWT` in your .env file. Then you can run this script with:
 * ```
 * TOKEN_ID=<TOKEN_ID> \
 * METADATA=<PATH> \
 * yarn hardhat run ./scripts/setERC1155Metadata.ts --network polygon-mumbai
 * ```
 */
async function main() {
    const tokenId = parseInt(process.env.TOKEN_ID || "0");
    const metadata = parseAndValidateMetadata();
    console.log(`Setting ERC1155 metadata for:`, { tokenId, metadata });
    const pinata = new sdk_1.default({ pinataJWTKey: process.env.PINATA_JWT });
    const pinResult = await pinata.pinJSONToIPFS(metadata, { pinataMetadata: { name: `${tokenId}-metadata.json` } });
    const metadataIpfsLink = `ipfs://${pinResult.IpfsHash}`;
    console.log(`Successfully uploaded metadata to IPFS:`, metadataIpfsLink);
    const [signer] = await utils_1.ethers.getSigners();
    const erc1155Deployment = await utils_hre_1.hre.deployments.get("MintableERC1155");
    const erc1155 = (await (0, utils_1.getContractFactory)("MintableERC1155", { signer })).attach(erc1155Deployment.address);
    const setTokenUriTx = await erc1155.setTokenURI(tokenId, metadataIpfsLink);
    console.log(`Setting token uri...`);
    console.log("Tx hash:", setTokenUriTx.hash);
    await setTokenUriTx.wait();
    console.log(`Successfully set token uri`);
}
function parseAndValidateMetadata() {
    if (!process.env.METADATA) {
        throw new Error("Missing path to a JSON file with token metadata. Pass it via env var METADATA=<PATH>");
    }
    const metadataFilePath = path_1.default.join(__dirname, "..", process.env.METADATA);
    const metadataFromFile = JSON.parse((0, fs_1.readFileSync)(metadataFilePath, "utf8"));
    const requiredKeys = ["name", "description", "image", "animation_url"];
    if (!requiredKeys.every((k) => k in metadataFromFile)) {
        throw new Error(`Invalid metadata: required keys ${requiredKeys}`);
    }
    requireIpfsLink(metadataFromFile.image, "image");
    requireIpfsLink(metadataFromFile.animation_url, "animation_url");
    return metadataFromFile;
}
function requireIpfsLink(ipfsLink, key) {
    // Make sure the image is an IPFS link
    if (!ipfsLink.startsWith("ipfs://")) {
        throw new Error(`Invalid metadata: '${key}' must be an IPFS link ipfs://<CID>`);
    }
    const cid = ipfsLink.split("ipfs://")[1];
    cid_1.CID.parse(cid); // throws if invalid
}
main().then(() => console.log("Done"), (error) => {
    console.log(error);
    process.exitCode = 1;
});
