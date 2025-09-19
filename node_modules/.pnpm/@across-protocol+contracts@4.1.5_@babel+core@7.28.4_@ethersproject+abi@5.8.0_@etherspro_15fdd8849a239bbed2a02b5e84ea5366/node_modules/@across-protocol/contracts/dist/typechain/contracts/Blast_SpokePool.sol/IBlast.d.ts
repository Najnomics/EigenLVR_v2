import type { BaseContract, BigNumber, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export interface IBlastInterface extends utils.Interface {
    functions: {
        "claimAllYield(address,address)": FunctionFragment;
        "claimMaxGas(address,address)": FunctionFragment;
        "configureClaimableGas()": FunctionFragment;
        "configureClaimableYield()": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "claimAllYield" | "claimMaxGas" | "configureClaimableGas" | "configureClaimableYield"): FunctionFragment;
    encodeFunctionData(functionFragment: "claimAllYield", values: [string, string]): string;
    encodeFunctionData(functionFragment: "claimMaxGas", values: [string, string]): string;
    encodeFunctionData(functionFragment: "configureClaimableGas", values?: undefined): string;
    encodeFunctionData(functionFragment: "configureClaimableYield", values?: undefined): string;
    decodeFunctionResult(functionFragment: "claimAllYield", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "claimMaxGas", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "configureClaimableGas", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "configureClaimableYield", data: BytesLike): Result;
    events: {};
}
export interface IBlast extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IBlastInterface;
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
        claimAllYield(contractAddress: string, recipientOfYield: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        claimMaxGas(contractAddress: string, recipientOfGas: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        configureClaimableGas(overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        configureClaimableYield(overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    claimAllYield(contractAddress: string, recipientOfYield: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    claimMaxGas(contractAddress: string, recipientOfGas: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    configureClaimableGas(overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    configureClaimableYield(overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        claimAllYield(contractAddress: string, recipientOfYield: string, overrides?: CallOverrides): Promise<BigNumber>;
        claimMaxGas(contractAddress: string, recipientOfGas: string, overrides?: CallOverrides): Promise<BigNumber>;
        configureClaimableGas(overrides?: CallOverrides): Promise<void>;
        configureClaimableYield(overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        claimAllYield(contractAddress: string, recipientOfYield: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        claimMaxGas(contractAddress: string, recipientOfGas: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        configureClaimableGas(overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        configureClaimableYield(overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        claimAllYield(contractAddress: string, recipientOfYield: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        claimMaxGas(contractAddress: string, recipientOfGas: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        configureClaimableGas(overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        configureClaimableYield(overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
