import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IERC20Rebasing, IERC20RebasingInterface } from "../../../contracts/Blast_SpokePool.sol/IERC20Rebasing";
export declare class IERC20Rebasing__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "recipient";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }];
        readonly name: "claim";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "enum IERC20Rebasing.YieldMode";
            readonly name: "yieldMode";
            readonly type: "uint8";
        }];
        readonly name: "configure";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "account";
            readonly type: "address";
        }];
        readonly name: "getClaimableAmount";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): IERC20RebasingInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IERC20Rebasing;
}
