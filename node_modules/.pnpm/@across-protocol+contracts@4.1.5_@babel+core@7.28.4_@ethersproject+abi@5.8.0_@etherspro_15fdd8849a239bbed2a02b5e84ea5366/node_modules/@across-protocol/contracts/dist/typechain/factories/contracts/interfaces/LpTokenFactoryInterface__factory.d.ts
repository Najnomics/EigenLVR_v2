import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { LpTokenFactoryInterface, LpTokenFactoryInterfaceInterface } from "../../../contracts/interfaces/LpTokenFactoryInterface";
export declare class LpTokenFactoryInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "createLpToken";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): LpTokenFactoryInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): LpTokenFactoryInterface;
}
