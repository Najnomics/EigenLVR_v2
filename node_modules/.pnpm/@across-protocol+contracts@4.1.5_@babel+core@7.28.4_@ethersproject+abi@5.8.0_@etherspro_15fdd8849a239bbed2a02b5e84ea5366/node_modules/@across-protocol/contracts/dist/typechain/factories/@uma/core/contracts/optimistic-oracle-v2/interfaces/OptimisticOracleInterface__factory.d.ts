import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { OptimisticOracleInterface, OptimisticOracleInterfaceInterface } from "../../../../../../@uma/core/contracts/optimistic-oracle-v2/interfaces/OptimisticOracleInterface";
export declare class OptimisticOracleInterface__factory {
    static readonly abi: readonly [{
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "disputer";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly indexed: false;
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }];
        readonly name: "DisputePrice";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly indexed: false;
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "expirationTimestamp";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "address";
            readonly name: "currency";
            readonly type: "address";
        }];
        readonly name: "ProposePrice";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly indexed: false;
            readonly internalType: "address";
            readonly name: "currency";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "reward";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "finalFee";
            readonly type: "uint256";
        }];
        readonly name: "RequestPrice";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "disputer";
            readonly type: "address";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly indexed: false;
            readonly internalType: "int256";
            readonly name: "price";
            readonly type: "int256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "payout";
            readonly type: "uint256";
        }];
        readonly name: "Settle";
        readonly type: "event";
    }, {
        readonly inputs: readonly [];
        readonly name: "ancillaryBytesLimit";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "defaultLiveness";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "disputePrice";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "disputer";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "disputePriceFor";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "finder";
        readonly outputs: readonly [{
            readonly internalType: "contract FinderInterface";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
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
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "getRequest";
        readonly outputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "address";
                readonly name: "proposer";
                readonly type: "address";
            }, {
                readonly internalType: "address";
                readonly name: "disputer";
                readonly type: "address";
            }, {
                readonly internalType: "contract IERC20";
                readonly name: "currency";
                readonly type: "address";
            }, {
                readonly internalType: "bool";
                readonly name: "settled";
                readonly type: "bool";
            }, {
                readonly internalType: "bool";
                readonly name: "refundOnDispute";
                readonly type: "bool";
            }, {
                readonly internalType: "int256";
                readonly name: "proposedPrice";
                readonly type: "int256";
            }, {
                readonly internalType: "int256";
                readonly name: "resolvedPrice";
                readonly type: "int256";
            }, {
                readonly internalType: "uint256";
                readonly name: "expirationTime";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "reward";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "finalFee";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "bond";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "customLiveness";
                readonly type: "uint256";
            }];
            readonly internalType: "struct OptimisticOracleInterface.Request";
            readonly name: "";
            readonly type: "tuple";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "getState";
        readonly outputs: readonly [{
            readonly internalType: "enum OptimisticOracleInterface.State";
            readonly name: "";
            readonly type: "uint8";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "hasPrice";
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
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }];
        readonly name: "proposePrice";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }];
        readonly name: "proposePriceFor";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "contract IERC20";
            readonly name: "currency";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "reward";
            readonly type: "uint256";
        }];
        readonly name: "requestPrice";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "";
            readonly type: "bytes32";
        }];
        readonly name: "requests";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "disputer";
            readonly type: "address";
        }, {
            readonly internalType: "contract IERC20";
            readonly name: "currency";
            readonly type: "address";
        }, {
            readonly internalType: "bool";
            readonly name: "settled";
            readonly type: "bool";
        }, {
            readonly internalType: "bool";
            readonly name: "refundOnDispute";
            readonly type: "bool";
        }, {
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }, {
            readonly internalType: "int256";
            readonly name: "resolvedPrice";
            readonly type: "int256";
        }, {
            readonly internalType: "uint256";
            readonly name: "expirationTime";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "reward";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "finalFee";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "bond";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "customLiveness";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "uint256";
            readonly name: "bond";
            readonly type: "uint256";
        }];
        readonly name: "setBond";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "totalBond";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "uint256";
            readonly name: "customLiveness";
            readonly type: "uint256";
        }];
        readonly name: "setCustomLiveness";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "setRefundOnDispute";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "settle";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "payout";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "timestamp";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }];
        readonly name: "settleAndGetPrice";
        readonly outputs: readonly [{
            readonly internalType: "int256";
            readonly name: "";
            readonly type: "int256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }];
        readonly name: "stampAncillaryData";
        readonly outputs: readonly [{
            readonly internalType: "bytes";
            readonly name: "";
            readonly type: "bytes";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): OptimisticOracleInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): OptimisticOracleInterface;
}
