import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface IMessageServiceInterface extends utils.Interface {
    functions: {
        "minimumFeeInWei()": FunctionFragment;
        "sendMessage(address,uint256,bytes)": FunctionFragment;
        "sender()": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "minimumFeeInWei" | "sendMessage" | "sender"): FunctionFragment;
    encodeFunctionData(functionFragment: "minimumFeeInWei", values?: undefined): string;
    encodeFunctionData(functionFragment: "sendMessage", values: [string, BigNumberish, BytesLike]): string;
    encodeFunctionData(functionFragment: "sender", values?: undefined): string;
    decodeFunctionResult(functionFragment: "minimumFeeInWei", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "sendMessage", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "sender", data: BytesLike): Result;
    events: {};
}
export interface IMessageService extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IMessageServiceInterface;
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
        minimumFeeInWei(overrides?: CallOverrides): Promise<[BigNumber]>;
        sendMessage(_to: string, _fee: BigNumberish, _calldata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        sender(overrides?: CallOverrides): Promise<[string]>;
    };
    minimumFeeInWei(overrides?: CallOverrides): Promise<BigNumber>;
    sendMessage(_to: string, _fee: BigNumberish, _calldata: BytesLike, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    sender(overrides?: CallOverrides): Promise<string>;
    callStatic: {
        minimumFeeInWei(overrides?: CallOverrides): Promise<BigNumber>;
        sendMessage(_to: string, _fee: BigNumberish, _calldata: BytesLike, overrides?: CallOverrides): Promise<void>;
        sender(overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        minimumFeeInWei(overrides?: CallOverrides): Promise<BigNumber>;
        sendMessage(_to: string, _fee: BigNumberish, _calldata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        sender(overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        minimumFeeInWei(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        sendMessage(_to: string, _fee: BigNumberish, _calldata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        sender(overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
