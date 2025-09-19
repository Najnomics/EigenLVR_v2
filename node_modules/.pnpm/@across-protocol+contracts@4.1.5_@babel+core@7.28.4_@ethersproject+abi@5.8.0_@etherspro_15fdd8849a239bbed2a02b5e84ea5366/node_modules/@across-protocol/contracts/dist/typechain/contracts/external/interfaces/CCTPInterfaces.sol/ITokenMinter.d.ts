import type { BaseContract, BigNumber, BytesLike, CallOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface ITokenMinterInterface extends utils.Interface {
    functions: {
        "burnLimitsPerMessage(address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "burnLimitsPerMessage"): FunctionFragment;
    encodeFunctionData(functionFragment: "burnLimitsPerMessage", values: [string]): string;
    decodeFunctionResult(functionFragment: "burnLimitsPerMessage", data: BytesLike): Result;
    events: {};
}
export interface ITokenMinter extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ITokenMinterInterface;
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
        burnLimitsPerMessage(token: string, overrides?: CallOverrides): Promise<[BigNumber]>;
    };
    burnLimitsPerMessage(token: string, overrides?: CallOverrides): Promise<BigNumber>;
    callStatic: {
        burnLimitsPerMessage(token: string, overrides?: CallOverrides): Promise<BigNumber>;
    };
    filters: {};
    estimateGas: {
        burnLimitsPerMessage(token: string, overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        burnLimitsPerMessage(token: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
