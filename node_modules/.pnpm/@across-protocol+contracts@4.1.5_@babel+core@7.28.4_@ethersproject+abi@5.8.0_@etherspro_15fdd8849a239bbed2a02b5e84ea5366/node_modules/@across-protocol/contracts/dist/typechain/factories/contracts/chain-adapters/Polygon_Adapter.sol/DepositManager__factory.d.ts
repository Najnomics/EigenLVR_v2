import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { DepositManager, DepositManagerInterface } from "../../../../contracts/chain-adapters/Polygon_Adapter.sol/DepositManager";
export declare class DepositManager__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "token";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "user";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }];
        readonly name: "depositERC20ForUser";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): DepositManagerInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): DepositManager;
}
