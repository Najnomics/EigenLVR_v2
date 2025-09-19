import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IL1ERC20Bridge, IL1ERC20BridgeInterface } from "../../../../contracts/chain-adapters/Blast_Adapter.sol/IL1ERC20Bridge";
export declare class IL1ERC20Bridge__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_localToken";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "_remoteToken";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "_to";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "_amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint32";
            readonly name: "_minGasLimit";
            readonly type: "uint32";
        }, {
            readonly internalType: "bytes";
            readonly name: "_extraData";
            readonly type: "bytes";
        }];
        readonly name: "bridgeERC20To";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): IL1ERC20BridgeInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IL1ERC20Bridge;
}
