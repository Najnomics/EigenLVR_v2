import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ICrossDomainMessengerUpgradeable, ICrossDomainMessengerUpgradeableInterface } from "../../../../../@openzeppelin/contracts-upgradeable/vendor/optimism/ICrossDomainMessengerUpgradeable";
export declare class ICrossDomainMessengerUpgradeable__factory {
    static readonly abi: readonly [{
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "bytes32";
            readonly name: "msgHash";
            readonly type: "bytes32";
        }];
        readonly name: "FailedRelayedMessage";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "bytes32";
            readonly name: "msgHash";
            readonly type: "bytes32";
        }];
        readonly name: "RelayedMessage";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "target";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "address";
            readonly name: "sender";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes";
            readonly name: "message";
            readonly type: "bytes";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "messageNonce";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "gasLimit";
            readonly type: "uint256";
        }];
        readonly name: "SentMessage";
        readonly type: "event";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_target";
            readonly type: "address";
        }, {
            readonly internalType: "bytes";
            readonly name: "_message";
            readonly type: "bytes";
        }, {
            readonly internalType: "uint32";
            readonly name: "_gasLimit";
            readonly type: "uint32";
        }];
        readonly name: "sendMessage";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "xDomainMessageSender";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): ICrossDomainMessengerUpgradeableInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ICrossDomainMessengerUpgradeable;
}
