import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ExtendedHubPoolInterface, ExtendedHubPoolInterfaceInterface } from "../../../contracts/BondToken.sol/ExtendedHubPoolInterface";
export declare class ExtendedHubPoolInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "l1TokenAmount";
            readonly type: "uint256";
        }];
        readonly name: "addLiquidity";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "claimProtocolFeesCaptured";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "disableL1TokenForLiquidityProvision";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "disputeRootBundle";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "emergencyDeleteProposal";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "enableL1TokenForLiquidityProvision";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "exchangeRateCurrent";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "chainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "groupIndex";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256[]";
            readonly name: "bundleLpFees";
            readonly type: "uint256[]";
        }, {
            readonly internalType: "int256[]";
            readonly name: "netSendAmounts";
            readonly type: "int256[]";
        }, {
            readonly internalType: "int256[]";
            readonly name: "runningBalances";
            readonly type: "int256[]";
        }, {
            readonly internalType: "uint8";
            readonly name: "leafId";
            readonly type: "uint8";
        }, {
            readonly internalType: "address[]";
            readonly name: "l1Tokens";
            readonly type: "address[]";
        }, {
            readonly internalType: "bytes32[]";
            readonly name: "proof";
            readonly type: "bytes32[]";
        }];
        readonly name: "executeRootBundle";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "liquidityUtilizationCurrent";
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
            readonly name: "l1Token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "relayedAmount";
            readonly type: "uint256";
        }];
        readonly name: "liquidityUtilizationPostRelay";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "loadEthForL2Calls";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "destinationChainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "poolRebalanceRoute";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "destinationToken";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256[]";
            readonly name: "bundleEvaluationBlockNumbers";
            readonly type: "uint256[]";
        }, {
            readonly internalType: "uint8";
            readonly name: "poolRebalanceLeafCount";
            readonly type: "uint8";
        }, {
            readonly internalType: "bytes32";
            readonly name: "poolRebalanceRoot";
            readonly type: "bytes32";
        }, {
            readonly internalType: "bytes32";
            readonly name: "relayerRefundRoot";
            readonly type: "bytes32";
        }, {
            readonly internalType: "bytes32";
            readonly name: "slowRelayRoot";
            readonly type: "bytes32";
        }];
        readonly name: "proposeRootBundle";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "chainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "functionData";
            readonly type: "bytes";
        }];
        readonly name: "relaySpokePoolAdminFunction";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "lpTokenAmount";
            readonly type: "uint256";
        }, {
            readonly internalType: "bool";
            readonly name: "sendEth";
            readonly type: "bool";
        }];
        readonly name: "removeLiquidity";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "rootBundleProposal";
        readonly outputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "bytes32";
                readonly name: "poolRebalanceRoot";
                readonly type: "bytes32";
            }, {
                readonly internalType: "bytes32";
                readonly name: "relayerRefundRoot";
                readonly type: "bytes32";
            }, {
                readonly internalType: "bytes32";
                readonly name: "slowRelayRoot";
                readonly type: "bytes32";
            }, {
                readonly internalType: "uint256";
                readonly name: "claimedBitMap";
                readonly type: "uint256";
            }, {
                readonly internalType: "address";
                readonly name: "proposer";
                readonly type: "address";
            }, {
                readonly internalType: "uint8";
                readonly name: "unclaimedPoolRebalanceLeafCount";
                readonly type: "uint8";
            }, {
                readonly internalType: "uint32";
                readonly name: "challengePeriodEndTimestamp";
                readonly type: "uint32";
            }];
            readonly internalType: "struct HubPoolInterface.RootBundle";
            readonly name: "";
            readonly type: "tuple";
        }];
        readonly stateMutability: "pure";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "contract IERC20";
            readonly name: "newBondToken";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "newBondAmount";
            readonly type: "uint256";
        }];
        readonly name: "setBond";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "l2ChainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "adapter";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "spokePool";
            readonly type: "address";
        }];
        readonly name: "setCrossChainContracts";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "originChainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "destinationChainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "originToken";
            readonly type: "address";
        }, {
            readonly internalType: "bool";
            readonly name: "depositsEnabled";
            readonly type: "bool";
        }];
        readonly name: "setDepositRoute";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "newIdentifier";
            readonly type: "bytes32";
        }];
        readonly name: "setIdentifier";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint32";
            readonly name: "newLiveness";
            readonly type: "uint32";
        }];
        readonly name: "setLiveness";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bool";
            readonly name: "pause";
            readonly type: "bool";
        }];
        readonly name: "setPaused";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "destinationChainId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "destinationToken";
            readonly type: "address";
        }];
        readonly name: "setPoolRebalanceRoute";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "newProtocolFeeCaptureAddress";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "newProtocolFeeCapturePct";
            readonly type: "uint256";
        }];
        readonly name: "setProtocolFeeCapture";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "l1Token";
            readonly type: "address";
        }];
        readonly name: "sync";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): ExtendedHubPoolInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ExtendedHubPoolInterface;
}
