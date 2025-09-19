import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IUSDCBridge, IUSDCBridgeInterface } from "../../../../../contracts/external/interfaces/LineaInterfaces.sol/IUSDCBridge";
export declare class IUSDCBridge__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "to";
            readonly type: "address";
        }];
        readonly name: "depositTo";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "usdc";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): IUSDCBridgeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IUSDCBridge;
}
