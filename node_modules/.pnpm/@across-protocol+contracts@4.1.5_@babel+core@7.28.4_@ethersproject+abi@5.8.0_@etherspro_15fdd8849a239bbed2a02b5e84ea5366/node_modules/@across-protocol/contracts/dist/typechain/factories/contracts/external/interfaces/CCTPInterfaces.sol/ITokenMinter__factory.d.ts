import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { ITokenMinter, ITokenMinterInterface } from "../../../../../contracts/external/interfaces/CCTPInterfaces.sol/ITokenMinter";
export declare class ITokenMinter__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "token";
            readonly type: "address";
        }];
        readonly name: "burnLimitsPerMessage";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): ITokenMinterInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): ITokenMinter;
}
