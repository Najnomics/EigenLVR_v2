import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export interface PolygonTokenBridgerInterface extends utils.Interface {
    functions: {
        "MATIC()": FunctionFragment;
        "callExit(bytes)": FunctionFragment;
        "destination()": FunctionFragment;
        "l1ChainId()": FunctionFragment;
        "l1PolygonRegistry()": FunctionFragment;
        "l1Weth()": FunctionFragment;
        "l2ChainId()": FunctionFragment;
        "l2WrappedMatic()": FunctionFragment;
        "retrieve(address)": FunctionFragment;
        "send(address,uint256)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "MATIC" | "callExit" | "destination" | "l1ChainId" | "l1PolygonRegistry" | "l1Weth" | "l2ChainId" | "l2WrappedMatic" | "retrieve" | "send"): FunctionFragment;
    encodeFunctionData(functionFragment: "MATIC", values?: undefined): string;
    encodeFunctionData(functionFragment: "callExit", values: [BytesLike]): string;
    encodeFunctionData(functionFragment: "destination", values?: undefined): string;
    encodeFunctionData(functionFragment: "l1ChainId", values?: undefined): string;
    encodeFunctionData(functionFragment: "l1PolygonRegistry", values?: undefined): string;
    encodeFunctionData(functionFragment: "l1Weth", values?: undefined): string;
    encodeFunctionData(functionFragment: "l2ChainId", values?: undefined): string;
    encodeFunctionData(functionFragment: "l2WrappedMatic", values?: undefined): string;
    encodeFunctionData(functionFragment: "retrieve", values: [string]): string;
    encodeFunctionData(functionFragment: "send", values: [string, BigNumberish]): string;
    decodeFunctionResult(functionFragment: "MATIC", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "callExit", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "destination", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l1ChainId", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l1PolygonRegistry", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l1Weth", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l2ChainId", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l2WrappedMatic", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "retrieve", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "send", data: BytesLike): Result;
    events: {};
}
export interface PolygonTokenBridger extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: PolygonTokenBridgerInterface;
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
        MATIC(overrides?: CallOverrides): Promise<[string]>;
        callExit(data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        destination(overrides?: CallOverrides): Promise<[string]>;
        l1ChainId(overrides?: CallOverrides): Promise<[BigNumber]>;
        l1PolygonRegistry(overrides?: CallOverrides): Promise<[string]>;
        l1Weth(overrides?: CallOverrides): Promise<[string]>;
        l2ChainId(overrides?: CallOverrides): Promise<[BigNumber]>;
        l2WrappedMatic(overrides?: CallOverrides): Promise<[string]>;
        retrieve(token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        send(token: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    MATIC(overrides?: CallOverrides): Promise<string>;
    callExit(data: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    destination(overrides?: CallOverrides): Promise<string>;
    l1ChainId(overrides?: CallOverrides): Promise<BigNumber>;
    l1PolygonRegistry(overrides?: CallOverrides): Promise<string>;
    l1Weth(overrides?: CallOverrides): Promise<string>;
    l2ChainId(overrides?: CallOverrides): Promise<BigNumber>;
    l2WrappedMatic(overrides?: CallOverrides): Promise<string>;
    retrieve(token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    send(token: string, amount: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        MATIC(overrides?: CallOverrides): Promise<string>;
        callExit(data: BytesLike, overrides?: CallOverrides): Promise<void>;
        destination(overrides?: CallOverrides): Promise<string>;
        l1ChainId(overrides?: CallOverrides): Promise<BigNumber>;
        l1PolygonRegistry(overrides?: CallOverrides): Promise<string>;
        l1Weth(overrides?: CallOverrides): Promise<string>;
        l2ChainId(overrides?: CallOverrides): Promise<BigNumber>;
        l2WrappedMatic(overrides?: CallOverrides): Promise<string>;
        retrieve(token: string, overrides?: CallOverrides): Promise<void>;
        send(token: string, amount: BigNumberish, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        MATIC(overrides?: CallOverrides): Promise<BigNumber>;
        callExit(data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        destination(overrides?: CallOverrides): Promise<BigNumber>;
        l1ChainId(overrides?: CallOverrides): Promise<BigNumber>;
        l1PolygonRegistry(overrides?: CallOverrides): Promise<BigNumber>;
        l1Weth(overrides?: CallOverrides): Promise<BigNumber>;
        l2ChainId(overrides?: CallOverrides): Promise<BigNumber>;
        l2WrappedMatic(overrides?: CallOverrides): Promise<BigNumber>;
        retrieve(token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        send(token: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        MATIC(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        callExit(data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        destination(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        l1ChainId(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        l1PolygonRegistry(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        l1Weth(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        l2ChainId(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        l2WrappedMatic(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        retrieve(token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        send(token: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
