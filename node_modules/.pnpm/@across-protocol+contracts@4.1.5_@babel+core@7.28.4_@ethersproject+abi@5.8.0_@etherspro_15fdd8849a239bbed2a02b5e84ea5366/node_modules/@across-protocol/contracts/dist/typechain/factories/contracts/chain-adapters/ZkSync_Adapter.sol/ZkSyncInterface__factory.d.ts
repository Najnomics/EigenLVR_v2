import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ZkSyncInterface, ZkSyncInterfaceInterface } from "../../../../contracts/chain-adapters/ZkSync_Adapter.sol/ZkSyncInterface";
export declare class ZkSyncInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "_l1GasPrice";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2GasLimit";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2GasPerPubdataByteLimit";
            readonly type: "uint256";
        }];
        readonly name: "l2TransactionBaseCost";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_contractL2";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2Value";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "_calldata";
            readonly type: "bytes";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2GasLimit";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "_l2GasPerPubdataByteLimit";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes[]";
            readonly name: "_factoryDeps";
            readonly type: "bytes[]";
        }, {
            readonly internalType: "address";
            readonly name: "_refundRecipient";
            readonly type: "address";
        }];
        readonly name: "requestL2Transaction";
        readonly outputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "canonicalTxHash";
            readonly type: "bytes32";
        }];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): ZkSyncInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ZkSyncInterface;
}
