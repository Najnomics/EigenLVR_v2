import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IL2GasPriceOracle, IL2GasPriceOracleInterface } from "../../../../../@scroll-tech/contracts/L1/rollup/IL2GasPriceOracle";
export declare class IL2GasPriceOracle__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "bytes";
            readonly name: "_message";
            readonly type: "bytes";
        }];
        readonly name: "calculateIntrinsicGasFee";
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
            readonly name: "_gasLimit";
            readonly type: "uint256";
        }];
        readonly name: "estimateCrossDomainMessageFee";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): IL2GasPriceOracleInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IL2GasPriceOracle;
}
