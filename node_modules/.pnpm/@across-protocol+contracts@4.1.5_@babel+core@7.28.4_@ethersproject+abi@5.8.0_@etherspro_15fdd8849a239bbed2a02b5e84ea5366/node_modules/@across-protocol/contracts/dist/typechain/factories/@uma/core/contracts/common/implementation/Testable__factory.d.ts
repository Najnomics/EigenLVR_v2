import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { Testable, TestableInterface } from "../../../../../../@uma/core/contracts/common/implementation/Testable";
export declare class Testable__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [];
        readonly name: "getCurrentTime";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "time";
            readonly type: "uint256";
        }];
        readonly name: "setCurrentTime";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "timerAddress";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): TestableInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): Testable;
}
