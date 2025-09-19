import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface IUSDCBridgeInterface extends utils.Interface {
    functions: {
        "depositTo(uint256,address)": FunctionFragment;
        "usdc()": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "depositTo" | "usdc"): FunctionFragment;
    encodeFunctionData(functionFragment: "depositTo", values: [BigNumberish, string]): string;
    encodeFunctionData(functionFragment: "usdc", values?: undefined): string;
    decodeFunctionResult(functionFragment: "depositTo", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "usdc", data: BytesLike): Result;
    events: {};
}
export interface IUSDCBridge extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IUSDCBridgeInterface;
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
        depositTo(amount: BigNumberish, to: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        usdc(overrides?: CallOverrides): Promise<[string]>;
    };
    depositTo(amount: BigNumberish, to: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    usdc(overrides?: CallOverrides): Promise<string>;
    callStatic: {
        depositTo(amount: BigNumberish, to: string, overrides?: CallOverrides): Promise<void>;
        usdc(overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        depositTo(amount: BigNumberish, to: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        usdc(overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        depositTo(amount: BigNumberish, to: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        usdc(overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
