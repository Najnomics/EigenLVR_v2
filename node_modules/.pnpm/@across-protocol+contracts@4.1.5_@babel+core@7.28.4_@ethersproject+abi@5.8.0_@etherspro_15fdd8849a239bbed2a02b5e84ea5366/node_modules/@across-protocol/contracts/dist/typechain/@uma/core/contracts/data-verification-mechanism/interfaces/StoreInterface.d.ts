import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../../common";
export declare namespace FixedPoint {
    type UnsignedStruct = {
        rawValue: BigNumberish;
    };
    type UnsignedStructOutput = [BigNumber] & {
        rawValue: BigNumber;
    };
}
export interface StoreInterfaceInterface extends utils.Interface {
    functions: {
        "computeFinalFee(address)": FunctionFragment;
        "computeRegularFee(uint256,uint256,(uint256))": FunctionFragment;
        "payOracleFees()": FunctionFragment;
        "payOracleFeesErc20(address,(uint256))": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "computeFinalFee" | "computeRegularFee" | "payOracleFees" | "payOracleFeesErc20"): FunctionFragment;
    encodeFunctionData(functionFragment: "computeFinalFee", values: [string]): string;
    encodeFunctionData(functionFragment: "computeRegularFee", values: [BigNumberish, BigNumberish, FixedPoint.UnsignedStruct]): string;
    encodeFunctionData(functionFragment: "payOracleFees", values?: undefined): string;
    encodeFunctionData(functionFragment: "payOracleFeesErc20", values: [string, FixedPoint.UnsignedStruct]): string;
    decodeFunctionResult(functionFragment: "computeFinalFee", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "computeRegularFee", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "payOracleFees", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "payOracleFeesErc20", data: BytesLike): Result;
    events: {};
}
export interface StoreInterface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: StoreInterfaceInterface;
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
        computeFinalFee(currency: string, overrides?: CallOverrides): Promise<[FixedPoint.UnsignedStructOutput]>;
        computeRegularFee(startTime: BigNumberish, endTime: BigNumberish, pfc: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<[
            FixedPoint.UnsignedStructOutput,
            FixedPoint.UnsignedStructOutput
        ] & {
            regularFee: FixedPoint.UnsignedStructOutput;
            latePenalty: FixedPoint.UnsignedStructOutput;
        }>;
        payOracleFees(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        payOracleFeesErc20(erc20Address: string, amount: FixedPoint.UnsignedStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    computeFinalFee(currency: string, overrides?: CallOverrides): Promise<FixedPoint.UnsignedStructOutput>;
    computeRegularFee(startTime: BigNumberish, endTime: BigNumberish, pfc: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<[
        FixedPoint.UnsignedStructOutput,
        FixedPoint.UnsignedStructOutput
    ] & {
        regularFee: FixedPoint.UnsignedStructOutput;
        latePenalty: FixedPoint.UnsignedStructOutput;
    }>;
    payOracleFees(overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    payOracleFeesErc20(erc20Address: string, amount: FixedPoint.UnsignedStruct, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        computeFinalFee(currency: string, overrides?: CallOverrides): Promise<FixedPoint.UnsignedStructOutput>;
        computeRegularFee(startTime: BigNumberish, endTime: BigNumberish, pfc: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<[
            FixedPoint.UnsignedStructOutput,
            FixedPoint.UnsignedStructOutput
        ] & {
            regularFee: FixedPoint.UnsignedStructOutput;
            latePenalty: FixedPoint.UnsignedStructOutput;
        }>;
        payOracleFees(overrides?: CallOverrides): Promise<void>;
        payOracleFeesErc20(erc20Address: string, amount: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        computeFinalFee(currency: string, overrides?: CallOverrides): Promise<BigNumber>;
        computeRegularFee(startTime: BigNumberish, endTime: BigNumberish, pfc: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<BigNumber>;
        payOracleFees(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        payOracleFeesErc20(erc20Address: string, amount: FixedPoint.UnsignedStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        computeFinalFee(currency: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        computeRegularFee(startTime: BigNumberish, endTime: BigNumberish, pfc: FixedPoint.UnsignedStruct, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        payOracleFees(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        payOracleFeesErc20(erc20Address: string, amount: FixedPoint.UnsignedStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
