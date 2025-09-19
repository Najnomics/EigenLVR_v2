import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ZkBridgeLike, ZkBridgeLikeInterface } from "../../../contracts/ZkSync_SpokePool.sol/ZkBridgeLike";
export declare class ZkBridgeLike__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_l1Receiver";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "_l2Token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_amount";
            readonly type: "uint256";
        }];
        readonly name: "withdraw";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): ZkBridgeLikeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ZkBridgeLike;
}
