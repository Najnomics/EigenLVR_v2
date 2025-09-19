import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface ZkBridgeLikeInterface extends utils.Interface {
    functions: {
        "deposit(address,address,uint256,uint256,uint256,address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "deposit"): FunctionFragment;
    encodeFunctionData(functionFragment: "deposit", values: [string, string, BigNumberish, BigNumberish, BigNumberish, string]): string;
    decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
    events: {};
}
export interface ZkBridgeLike extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ZkBridgeLikeInterface;
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
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
