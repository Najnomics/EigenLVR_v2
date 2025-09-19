import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface AcrossMessageHandlerInterface extends utils.Interface {
    functions: {
        "handleV3AcrossMessage(address,uint256,address,bytes)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "handleV3AcrossMessage"): FunctionFragment;
    encodeFunctionData(functionFragment: "handleV3AcrossMessage", values: [string, BigNumberish, string, BytesLike]): string;
    decodeFunctionResult(functionFragment: "handleV3AcrossMessage", data: BytesLike): Result;
    events: {};
}
export interface AcrossMessageHandler extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: AcrossMessageHandlerInterface;
    queryFilter<TEvent extends TypedEvent>(event: TypedEventFilter<TEvent>, fromBlockOrBlockhash?: string | number | undefined, toBlock?: string | number | undefined): Promise<Array<TEvent>>;
    listeners<TEvent extends TypedEvent>(eventFilter?: TypedEventFilter<TEvent>): Array<TypedListener<TEvent>>;
    listeners(eventName?: string): Array<Listener>;
    removeAllListeners<TEvent extends TypedEvent>(eventFilter: TypedEventFilter<TEvent>): this;
    removeAllListeners(eventName?: string): this;
    off: OnEvent<this>;
    on: OnEvent<this>;
    once: OnEvent<this>;
    removeListener: OnEvent<this>;
    functions: {
        handleV3AcrossMessage(tokenSent: string, amount: BigNumberish, relayer: string, message: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    handleV3AcrossMessage(tokenSent: string, amount: BigNumberish, relayer: string, message: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        handleV3AcrossMessage(tokenSent: string, amount: BigNumberish, relayer: string, message: BytesLike, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        handleV3AcrossMessage(tokenSent: string, amount: BigNumberish, relayer: string, message: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        handleV3AcrossMessage(tokenSent: string, amount: BigNumberish, relayer: string, message: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
