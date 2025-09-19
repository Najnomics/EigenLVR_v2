import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IBridgeMessageReceiver, IBridgeMessageReceiverInterface } from "../../../contracts/PolygonZkEVM_SpokePool.sol/IBridgeMessageReceiver";
export declare class IBridgeMessageReceiver__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "originAddress";
            readonly type: "address";
        }, {
            readonly internalType: "uint32";
            readonly name: "originNetwork";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "data";
            readonly type: "bytes";
        }];
        readonly name: "onMessageReceived";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): IBridgeMessageReceiverInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IBridgeMessageReceiver;
}
