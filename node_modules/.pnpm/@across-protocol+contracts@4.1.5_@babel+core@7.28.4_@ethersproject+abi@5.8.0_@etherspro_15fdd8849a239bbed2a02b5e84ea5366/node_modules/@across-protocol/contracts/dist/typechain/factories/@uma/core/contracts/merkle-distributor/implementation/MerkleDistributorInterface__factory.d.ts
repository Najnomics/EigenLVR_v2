import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { MerkleDistributorInterface, MerkleDistributorInterfaceInterface } from "../../../../../../@uma/core/contracts/merkle-distributor/implementation/MerkleDistributorInterface";
export declare class MerkleDistributorInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "windowIndex";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "amount";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "accountIndex";
                readonly type: "uint256";
            }, {
                readonly internalType: "address";
                readonly name: "account";
                readonly type: "address";
            }, {
                readonly internalType: "bytes32[]";
                readonly name: "merkleProof";
                readonly type: "bytes32[]";
            }];
            readonly internalType: "struct MerkleDistributorInterface.Claim";
            readonly name: "_claim";
            readonly type: "tuple";
        }];
        readonly name: "claim";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "windowIndex";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "amount";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "accountIndex";
                readonly type: "uint256";
            }, {
                readonly internalType: "address";
                readonly name: "account";
                readonly type: "address";
            }, {
                readonly internalType: "bytes32[]";
                readonly name: "merkleProof";
                readonly type: "bytes32[]";
            }];
            readonly internalType: "struct MerkleDistributorInterface.Claim[]";
            readonly name: "claims";
            readonly type: "tuple[]";
        }];
        readonly name: "claimMulti";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "windowIndex";
            readonly type: "uint256";
        }];
        readonly name: "getRewardTokenForWindow";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): MerkleDistributorInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): MerkleDistributorInterface;
}
