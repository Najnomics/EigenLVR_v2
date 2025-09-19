import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export interface IERC20RebasingInterface extends utils.Interface {
    functions: {
        "claim(address,uint256)": FunctionFragment;
        "configure(uint8)": FunctionFragment;
        "getClaimableAmount(address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "claim" | "configure" | "getClaimableAmount"): FunctionFragment;
    encodeFunctionData(functionFragment: "claim", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "configure", values: [BigNumberish]): string;
    encodeFunctionData(functionFragment: "getClaimableAmount", values: [string]): string;
    decodeFunctionResult(functionFragment: "claim", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "configure", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "getClaimableAmount", data: BytesLike): Result;
    events: {};
}
export interface IERC20Rebasing extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IERC20RebasingInterface;
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
        claim(recipient: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        configure(yieldMode: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        getClaimableAmount(account: string, overrides?: CallOverrides): Promise<[BigNumber]>;
    };
    claim(recipient: string, amount: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    configure(yieldMode: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    getClaimableAmount(account: string, overrides?: CallOverrides): Promise<BigNumber>;
    callStatic: {
        claim(recipient: string, amount: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        configure(yieldMode: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        getClaimableAmount(account: string, overrides?: CallOverrides): Promise<BigNumber>;
    };
    filters: {};
    estimateGas: {
        claim(recipient: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        configure(yieldMode: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        getClaimableAmount(account: string, overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        claim(recipient: string, amount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        configure(yieldMode: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        getClaimableAmount(account: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
