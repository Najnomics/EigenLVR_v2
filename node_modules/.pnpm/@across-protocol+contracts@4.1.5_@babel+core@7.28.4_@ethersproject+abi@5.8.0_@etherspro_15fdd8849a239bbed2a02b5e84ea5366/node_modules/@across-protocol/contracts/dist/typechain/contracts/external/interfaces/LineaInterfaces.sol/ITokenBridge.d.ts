import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface ITokenBridgeInterface extends utils.Interface {
    functions: {
        "bridgeToken(address,uint256,address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "bridgeToken"): FunctionFragment;
    encodeFunctionData(functionFragment: "bridgeToken", values: [string, BigNumberish, string]): string;
    decodeFunctionResult(functionFragment: "bridgeToken", data: BytesLike): Result;
    events: {};
}
export interface ITokenBridge extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ITokenBridgeInterface;
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
        bridgeToken(_token: string, _amount: BigNumberish, _recipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    bridgeToken(_token: string, _amount: BigNumberish, _recipient: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        bridgeToken(_token: string, _amount: BigNumberish, _recipient: string, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        bridgeToken(_token: string, _amount: BigNumberish, _recipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        bridgeToken(_token: string, _amount: BigNumberish, _recipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
