import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface IL2GasPriceOracleInterface extends utils.Interface {
    functions: {
        "calculateIntrinsicGasFee(bytes)": FunctionFragment;
        "estimateCrossDomainMessageFee(uint256)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "calculateIntrinsicGasFee" | "estimateCrossDomainMessageFee"): FunctionFragment;
    encodeFunctionData(functionFragment: "calculateIntrinsicGasFee", values: [BytesLike]): string;
    encodeFunctionData(functionFragment: "estimateCrossDomainMessageFee", values: [BigNumberish]): string;
    decodeFunctionResult(functionFragment: "calculateIntrinsicGasFee", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "estimateCrossDomainMessageFee", data: BytesLike): Result;
    events: {};
}
export interface IL2GasPriceOracle extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IL2GasPriceOracleInterface;
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
        calculateIntrinsicGasFee(_message: BytesLike, overrides?: CallOverrides): Promise<[BigNumber]>;
        estimateCrossDomainMessageFee(_gasLimit: BigNumberish, overrides?: CallOverrides): Promise<[BigNumber]>;
    };
    calculateIntrinsicGasFee(_message: BytesLike, overrides?: CallOverrides): Promise<BigNumber>;
    estimateCrossDomainMessageFee(_gasLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    callStatic: {
        calculateIntrinsicGasFee(_message: BytesLike, overrides?: CallOverrides): Promise<BigNumber>;
        estimateCrossDomainMessageFee(_gasLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    };
    filters: {};
    estimateGas: {
        calculateIntrinsicGasFee(_message: BytesLike, overrides?: CallOverrides): Promise<BigNumber>;
        estimateCrossDomainMessageFee(_gasLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        calculateIntrinsicGasFee(_message: BytesLike, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        estimateCrossDomainMessageFee(_gasLimit: BigNumberish, overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
