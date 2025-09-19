import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { AddressWhitelistInterface, AddressWhitelistInterfaceInterface } from "../../../../../../@uma/core/contracts/common/interfaces/AddressWhitelistInterface";
export declare class AddressWhitelistInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "newElement";
            readonly type: "address";
        }];
        readonly name: "addToWhitelist";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "getWhitelist";
        readonly outputs: readonly [{
            readonly internalType: "address[]";
            readonly name: "";
            readonly type: "address[]";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "newElement";
            readonly type: "address";
        }];
        readonly name: "isOnWhitelist";
        readonly outputs: readonly [{
            readonly internalType: "bool";
            readonly name: "";
            readonly type: "bool";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "newElement";
            readonly type: "address";
        }];
        readonly name: "removeFromWhitelist";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): AddressWhitelistInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): AddressWhitelistInterface;
}
