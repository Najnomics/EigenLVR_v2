import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../common";
export interface ITelepathyHandlerInterface extends utils.Interface {
    functions: {
        "handleTelepathy(uint16,address,bytes)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "handleTelepathy"): FunctionFragment;
    encodeFunctionData(functionFragment: "handleTelepathy", values: [BigNumberish, string, BytesLike]): string;
    decodeFunctionResult(functionFragment: "handleTelepathy", data: BytesLike): Result;
    events: {};
}
export interface ITelepathyHandler extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ITelepathyHandlerInterface;
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
        handleTelepathy(_sourceChainId: BigNumberish, _senderAddress: string, _data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    handleTelepathy(_sourceChainId: BigNumberish, _senderAddress: string, _data: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        handleTelepathy(_sourceChainId: BigNumberish, _senderAddress: string, _data: BytesLike, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        handleTelepathy(_sourceChainId: BigNumberish, _senderAddress: string, _data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        handleTelepathy(_sourceChainId: BigNumberish, _senderAddress: string, _data: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
