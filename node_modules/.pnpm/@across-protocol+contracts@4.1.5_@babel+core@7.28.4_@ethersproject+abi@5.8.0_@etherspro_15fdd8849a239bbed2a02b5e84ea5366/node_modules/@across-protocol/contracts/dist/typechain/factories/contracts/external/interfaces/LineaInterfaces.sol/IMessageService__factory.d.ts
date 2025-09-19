import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IMessageService, IMessageServiceInterface } from "../../../../../contracts/external/interfaces/LineaInterfaces.sol/IMessageService";
export declare class IMessageService__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [];
        readonly name: "minimumFeeInWei";
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
            readonly name: "_to";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_fee";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "_calldata";
            readonly type: "bytes";
        }];
        readonly name: "sendMessage";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "sender";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): IMessageServiceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IMessageService;
}
