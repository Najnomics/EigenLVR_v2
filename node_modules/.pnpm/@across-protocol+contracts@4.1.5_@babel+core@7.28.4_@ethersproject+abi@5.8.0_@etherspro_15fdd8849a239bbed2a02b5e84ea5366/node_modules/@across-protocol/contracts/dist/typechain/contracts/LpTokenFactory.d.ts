import type { BaseContract, BigNumber, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../common";
export interface LpTokenFactoryInterface extends utils.Interface {
    functions: {
        "createLpToken(address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "createLpToken"): FunctionFragment;
    encodeFunctionData(functionFragment: "createLpToken", values: [string]): string;
    decodeFunctionResult(functionFragment: "createLpToken", data: BytesLike): Result;
    events: {};
}
export interface LpTokenFactory extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: LpTokenFactoryInterface;
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
        createLpToken(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    createLpToken(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        createLpToken(l1Token: string, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        createLpToken(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        createLpToken(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
