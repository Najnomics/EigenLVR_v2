import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { PolygonRegistry, PolygonRegistryInterface } from "../../../contracts/PolygonTokenBridger.sol/PolygonRegistry";
export declare class PolygonRegistry__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [];
        readonly name: "erc20Predicate";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): PolygonRegistryInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): PolygonRegistry;
}
