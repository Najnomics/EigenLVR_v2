import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { EIP712CrossChainUpgradeable, EIP712CrossChainUpgradeableInterface } from "../../../contracts/upgradeable/EIP712CrossChainUpgradeable";
export declare class EIP712CrossChainUpgradeable__factory {
    static readonly abi: readonly [{
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: false;
            readonly internalType: "uint8";
            readonly name: "version";
            readonly type: "uint8";
        }];
        readonly name: "Initialized";
        readonly type: "event";
    }];
    static createInterface(): EIP712CrossChainUpgradeableInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): EIP712CrossChainUpgradeable;
}
