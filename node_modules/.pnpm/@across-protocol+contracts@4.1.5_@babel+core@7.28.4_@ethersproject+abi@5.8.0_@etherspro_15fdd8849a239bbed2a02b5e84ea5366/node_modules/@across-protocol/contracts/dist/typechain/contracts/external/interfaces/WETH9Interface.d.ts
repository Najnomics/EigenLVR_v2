import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface WETH9InterfaceInterface extends utils.Interface {
    functions: {
        "balanceOf(address)": FunctionFragment;
        "deposit()": FunctionFragment;
        "transfer(address,uint256)": FunctionFragment;
        "withdraw(uint256)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "balanceOf" | "deposit" | "transfer" | "withdraw"): FunctionFragment;
    encodeFunctionData(functionFragment: "balanceOf", values: [string]): string;
    encodeFunctionData(functionFragment: "deposit", values?: undefined): string;
    encodeFunctionData(functionFragment: "transfer", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "withdraw", values: [BigNumberish]): string;
    decodeFunctionResult(functionFragment: "balanceOf", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "transfer", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;
    events: {};
}
export interface WETH9Interface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: WETH9InterfaceInterface;
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
        balanceOf(guy: string, overrides?: CallOverrides): Promise<[BigNumber] & {
            wad: BigNumber;
        }>;
        deposit(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        transfer(guy: string, wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        withdraw(wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    balanceOf(guy: string, overrides?: CallOverrides): Promise<BigNumber>;
    deposit(overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    transfer(guy: string, wad: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    withdraw(wad: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        balanceOf(guy: string, overrides?: CallOverrides): Promise<BigNumber>;
        deposit(overrides?: CallOverrides): Promise<void>;
        transfer(guy: string, wad: BigNumberish, overrides?: CallOverrides): Promise<boolean>;
        withdraw(wad: BigNumberish, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        balanceOf(guy: string, overrides?: CallOverrides): Promise<BigNumber>;
        deposit(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        transfer(guy: string, wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        withdraw(wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        balanceOf(guy: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        deposit(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        transfer(guy: string, wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        withdraw(wad: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
