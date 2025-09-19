import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ITelepathyHandler, ITelepathyHandlerInterface } from "../../../../../contracts/external/interfaces/SuccinctInterfaces.sol/ITelepathyHandler";
export declare class ITelepathyHandler__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint16";
            readonly name: "_sourceChainId";
            readonly type: "uint16";
        }, {
            readonly internalType: "address";
            readonly name: "_senderAddress";
            readonly type: "address";
        }, {
            readonly internalType: "bytes";
            readonly name: "_data";
            readonly type: "bytes";
        }];
        readonly name: "handleTelepathy";
        readonly outputs: readonly [{
            readonly internalType: "bytes4";
            readonly name: "";
            readonly type: "bytes4";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): ITelepathyHandlerInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ITelepathyHandler;
}
