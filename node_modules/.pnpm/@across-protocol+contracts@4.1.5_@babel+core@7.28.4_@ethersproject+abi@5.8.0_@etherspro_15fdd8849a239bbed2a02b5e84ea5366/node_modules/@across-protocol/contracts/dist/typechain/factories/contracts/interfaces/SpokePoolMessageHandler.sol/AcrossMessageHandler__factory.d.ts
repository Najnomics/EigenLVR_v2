import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { AcrossMessageHandler, AcrossMessageHandlerInterface } from "../../../../contracts/interfaces/SpokePoolMessageHandler.sol/AcrossMessageHandler";
export declare class AcrossMessageHandler__factory {
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "tokenSent";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "amount";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "relayer";
            readonly type: "address";
        }, {
            readonly internalType: "bytes";
            readonly name: "message";
            readonly type: "bytes";
        }];
        readonly name: "handleV3AcrossMessage";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): AcrossMessageHandlerInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): AcrossMessageHandler;
}
