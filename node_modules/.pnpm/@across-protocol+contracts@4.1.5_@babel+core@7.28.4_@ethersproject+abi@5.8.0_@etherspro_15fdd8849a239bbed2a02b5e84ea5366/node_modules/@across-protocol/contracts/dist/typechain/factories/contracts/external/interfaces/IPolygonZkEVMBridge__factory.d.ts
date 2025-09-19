import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IPolygonZkEVMBridge, IPolygonZkEVMBridgeInterface } from "../../../../contracts/external/interfaces/IPolygonZkEVMBridge";
export declare class IPolygonZkEVMBridge__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint32";
            readonly name: "destinationNetwork";
            readonly type: "uint32";
        }, {
            readonly internalType: "address";
            readonly name: "destinationAddress";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "token";
            readonly type: "address";
        }, {
            readonly internalType: "bool";
            readonly name: "forceUpdateGlobalExitRoot";
            readonly type: "bool";
        }, {
            readonly internalType: "bytes";
            readonly name: "permitData";
            readonly type: "bytes";
        }];
        readonly name: "bridgeAsset";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint32";
            readonly name: "destinationNetwork";
            readonly type: "uint32";
        }, {
            readonly internalType: "address";
            readonly name: "destinationAddress";
            readonly type: "address";
        }, {
            readonly internalType: "bool";
            readonly name: "forceUpdateGlobalExitRoot";
            readonly type: "bool";
        }, {
            readonly internalType: "bytes";
            readonly name: "metadata";
            readonly type: "bytes";
        }];
        readonly name: "bridgeMessage";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): IPolygonZkEVMBridgeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IPolygonZkEVMBridge;
}
