import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ITelepathyBroadcaster, ITelepathyBroadcasterInterface } from "../../../../../contracts/external/interfaces/SuccinctInterfaces.sol/ITelepathyBroadcaster";
export declare class ITelepathyBroadcaster__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint16";
            readonly name: "_recipientChainId";
            readonly type: "uint16";
        }, {
            readonly internalType: "address";
            readonly name: "_recipientAddress";
            readonly type: "address";
        }, {
            readonly internalType: "bytes";
            readonly name: "_data";
            readonly type: "bytes";
        }];
        readonly name: "send";
        readonly outputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "";
            readonly type: "bytes32";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): ITelepathyBroadcasterInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ITelepathyBroadcaster;
}
