import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ITokenBridge, ITokenBridgeInterface } from "../../../../../contracts/external/interfaces/LineaInterfaces.sol/ITokenBridge";
export declare class ITokenBridge__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "_recipient";
            readonly type: "address";
        }];
        readonly name: "bridgeToken";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): ITokenBridgeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ITokenBridge;
}
