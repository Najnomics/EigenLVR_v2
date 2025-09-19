import type { BaseContract, BigNumber, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export interface PolygonRegistryInterface extends utils.Interface {
    functions: {
        "erc20Predicate()": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "erc20Predicate"): FunctionFragment;
    encodeFunctionData(functionFragment: "erc20Predicate", values?: undefined): string;
    decodeFunctionResult(functionFragment: "erc20Predicate", data: BytesLike): Result;
    events: {};
}
export interface PolygonRegistry extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: PolygonRegistryInterface;
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
        erc20Predicate(overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    erc20Predicate(overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        erc20Predicate(overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        erc20Predicate(overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        erc20Predicate(overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
