import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { SynthetixBridgeToBase, SynthetixBridgeToBaseInterface } from "../../../contracts/Optimism_SpokePool.sol/SynthetixBridgeToBase";
export declare class SynthetixBridgeToBase__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "to";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }];
        readonly name: "withdrawTo";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): SynthetixBridgeToBaseInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): SynthetixBridgeToBase;
}
