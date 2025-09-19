import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IL2ETH, IL2ETHInterface } from "../../../contracts/ZkSync_SpokePool.sol/IL2ETH";
export declare class IL2ETH__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_l1Receiver";
            readonly type: "address";
        }];
        readonly name: "withdraw";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): IL2ETHInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IL2ETH;
}
