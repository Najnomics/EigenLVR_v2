import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { FinderInterface, FinderInterfaceInterface } from "../../../../../../@uma/core/contracts/data-verification-mechanism/interfaces/FinderInterface";
export declare class FinderInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "interfaceName";
            readonly type: "bytes32";
        }, {
            readonly internalType: "address";
            readonly name: "implementationAddress";
            readonly type: "address";
        }];
        readonly name: "changeImplementationAddress";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "interfaceName";
            readonly type: "bytes32";
        }];
        readonly name: "getImplementationAddress";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): FinderInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): FinderInterface;
}
