import type { BaseContract, BigNumber, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../../common";
export interface IdentifierWhitelistInterfaceInterface extends utils.Interface {
    functions: {
        "addSupportedIdentifier(bytes32)": FunctionFragment;
        "isIdentifierSupported(bytes32)": FunctionFragment;
        "removeSupportedIdentifier(bytes32)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "addSupportedIdentifier" | "isIdentifierSupported" | "removeSupportedIdentifier"): FunctionFragment;
    encodeFunctionData(functionFragment: "addSupportedIdentifier", values: [BytesLike]): string;
    encodeFunctionData(functionFragment: "isIdentifierSupported", values: [BytesLike]): string;
    encodeFunctionData(functionFragment: "removeSupportedIdentifier", values: [BytesLike]): string;
    decodeFunctionResult(functionFragment: "addSupportedIdentifier", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "isIdentifierSupported", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "removeSupportedIdentifier", data: BytesLike): Result;
    events: {};
}
export interface IdentifierWhitelistInterface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IdentifierWhitelistInterfaceInterface;
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
        addSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        isIdentifierSupported(identifier: BytesLike, overrides?: CallOverrides): Promise<[boolean]>;
        removeSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    addSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    isIdentifierSupported(identifier: BytesLike, overrides?: CallOverrides): Promise<boolean>;
    removeSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        addSupportedIdentifier(identifier: BytesLike, overrides?: CallOverrides): Promise<void>;
        isIdentifierSupported(identifier: BytesLike, overrides?: CallOverrides): Promise<boolean>;
        removeSupportedIdentifier(identifier: BytesLike, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        addSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        isIdentifierSupported(identifier: BytesLike, overrides?: CallOverrides): Promise<BigNumber>;
        removeSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        addSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        isIdentifierSupported(identifier: BytesLike, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        removeSupportedIdentifier(identifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
