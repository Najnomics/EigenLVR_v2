import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { StoreInterface, StoreInterfaceInterface } from "../../../../../../@uma/core/contracts/data-verification-mechanism/interfaces/StoreInterface";
export declare class StoreInterface__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "currency";
            readonly type: "address";
        }];
        readonly name: "computeFinalFee";
        readonly outputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "rawValue";
                readonly type: "uint256";
            }];
            readonly internalType: "struct FixedPoint.Unsigned";
            readonly name: "";
            readonly type: "tuple";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "startTime";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "endTime";
            readonly type: "uint256";
        }, {
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "rawValue";
                readonly type: "uint256";
            }];
            readonly internalType: "struct FixedPoint.Unsigned";
            readonly name: "pfc";
            readonly type: "tuple";
        }];
        readonly name: "computeRegularFee";
        readonly outputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "rawValue";
                readonly type: "uint256";
            }];
            readonly internalType: "struct FixedPoint.Unsigned";
            readonly name: "regularFee";
            readonly type: "tuple";
        }, {
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "rawValue";
                readonly type: "uint256";
            }];
            readonly internalType: "struct FixedPoint.Unsigned";
            readonly name: "latePenalty";
            readonly type: "tuple";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "payOracleFees";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "erc20Address";
            readonly type: "address";
        }, {
            readonly components: readonly [{
                readonly internalType: "uint256";
                readonly name: "rawValue";
                readonly type: "uint256";
            }];
            readonly internalType: "struct FixedPoint.Unsigned";
            readonly name: "amount";
            readonly type: "tuple";
        }];
        readonly name: "payOracleFeesErc20";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): StoreInterfaceInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): StoreInterface;
}
