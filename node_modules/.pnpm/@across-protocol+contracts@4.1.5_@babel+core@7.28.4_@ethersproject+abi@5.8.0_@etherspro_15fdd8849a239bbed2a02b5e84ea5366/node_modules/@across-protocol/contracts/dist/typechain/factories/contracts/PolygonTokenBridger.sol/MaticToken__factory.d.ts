import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { MaticToken, MaticTokenInterface } from "../../../contracts/PolygonTokenBridger.sol/MaticToken";
export declare class MaticToken__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }];
        readonly name: "withdraw";
        readonly outputs: readonly [];
        readonly stateMutability: "payable";
        readonly type: "function";
    }];
    static createInterface(): MaticTokenInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): MaticToken;
}
