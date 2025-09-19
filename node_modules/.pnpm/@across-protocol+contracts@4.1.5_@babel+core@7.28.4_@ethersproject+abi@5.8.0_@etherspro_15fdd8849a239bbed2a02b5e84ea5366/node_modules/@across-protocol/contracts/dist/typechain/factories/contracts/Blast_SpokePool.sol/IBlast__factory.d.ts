import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IBlast, IBlastInterface } from "../../../contracts/Blast_SpokePool.sol/IBlast";
export declare class IBlast__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "contractAddress";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "recipientOfYield";
            readonly type: "address";
        }];
        readonly name: "claimAllYield";
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
            readonly name: "contractAddress";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "recipientOfGas";
            readonly type: "address";
        }];
        readonly name: "claimMaxGas";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "configureClaimableGas";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "configureClaimableYield";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): IBlastInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IBlast;
}
