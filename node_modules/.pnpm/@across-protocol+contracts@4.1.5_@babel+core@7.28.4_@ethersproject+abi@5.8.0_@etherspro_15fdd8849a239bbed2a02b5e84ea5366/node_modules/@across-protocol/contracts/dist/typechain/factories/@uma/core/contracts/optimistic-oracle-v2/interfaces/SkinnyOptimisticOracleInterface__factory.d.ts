import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { SkinnyOptimisticOracleInterface, SkinnyOptimisticOracleInterfaceInterface } from "../../../../../../@uma/core/contracts/optimistic-oracle-v2/interfaces/SkinnyOptimisticOracleInterface";
export declare class SkinnyOptimisticOracleInterface__factory {
    static readonly abi: readonly [{
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
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
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
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
        }, {
            readonly internalType: "address";
            readonly name: "disputer";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
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
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
        }];
        readonly name: "getState";
        readonly outputs: readonly [{
            readonly internalType: "enum OptimisticOracleInterface.State";
            readonly name: "";
            readonly type: "uint8";
        }];
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
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
        }];
        readonly name: "hasPrice";
        readonly outputs: readonly [{
            readonly internalType: "bool";
            readonly name: "";
            readonly type: "bool";
        }];
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
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
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
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
        }, {
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
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
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
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
        }, {
            readonly internalType: "uint256";
            readonly name: "bond";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "customLiveness";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "proposer";
            readonly type: "address";
        }, {
            readonly internalType: "int256";
            readonly name: "proposedPrice";
            readonly type: "int256";
        }];
        readonly name: "requestAndProposePriceFor";
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
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
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
        }, {
            readonly internalType: "uint256";
            readonly name: "bond";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "customLiveness";
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
            readonly internalType: "address";
            readonly name: "requester";
            readonly type: "address";
        }, {
            readonly internalType: "bytes32";
            readonly name: "identifier";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint32";
            readonly name: "timestamp";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "ancillaryData";
            readonly type: "bytes";
        }, {
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
            readonly internalType: "struct SkinnyOptimisticOracleInterface.Request";
            readonly name: "request";
            readonly type: "tuple";
        }];
        readonly name: "settle";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "payout";
            readonly type: "uint256";
        }, {
            readonly internalType: "int256";
            readonly name: "resolvedPrice";
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
        readonly stateMutability: "pure";
        readonly type: "function";
    }];
    static createInterface(): SkinnyOptimisticOracleInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): SkinnyOptimisticOracleInterface;
}
