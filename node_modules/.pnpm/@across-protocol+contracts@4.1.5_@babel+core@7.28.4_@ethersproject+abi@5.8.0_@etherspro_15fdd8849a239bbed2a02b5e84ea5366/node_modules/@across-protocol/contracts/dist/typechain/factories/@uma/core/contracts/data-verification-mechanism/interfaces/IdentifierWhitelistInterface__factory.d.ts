import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IdentifierWhitelistInterface, IdentifierWhitelistInterfaceInterface } from "../../../../../../@uma/core/contracts/data-verification-mechanism/interfaces/IdentifierWhitelistInterface";
export declare class IdentifierWhitelistInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }];
        readonly name: "addSupportedIdentifier";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }];
        readonly name: "isIdentifierSupported";
        readonly outputs: readonly [{
            readonly internalType: "bool";
            readonly name: "";
            readonly type: "bool";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }];
        readonly name: "removeSupportedIdentifier";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): IdentifierWhitelistInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IdentifierWhitelistInterface;
}
