import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { PolygonERC20Predicate, PolygonERC20PredicateInterface } from "../../../contracts/PolygonTokenBridger.sol/PolygonERC20Predicate";
export declare class PolygonERC20Predicate__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "bytes";
            readonly name: "data";
            readonly type: "bytes";
        }];
        readonly name: "startExitWithBurntTokens";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): PolygonERC20PredicateInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): PolygonERC20Predicate;
}
