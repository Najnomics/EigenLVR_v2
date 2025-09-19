import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ZkBridgeLike, ZkBridgeLikeInterface } from "../../../../contracts/chain-adapters/ZkSync_Adapter.sol/ZkBridgeLike";
export declare class ZkBridgeLike__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_l2Receiver";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "_l1Token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2TxGasLimit";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2TxGasPerPubdataByte";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "_refundRecipient";
            readonly type: "address";
        }];
        readonly name: "deposit";
        readonly outputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "txHash";
            readonly type: "bytes32";
        }];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): ZkBridgeLikeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ZkBridgeLike;
}
