import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface ZkSyncInterfaceInterface extends utils.Interface {
    functions: {
        "l2TransactionBaseCost(uint256,uint256,uint256)": FunctionFragment;
        "requestL2Transaction(address,uint256,bytes,uint256,uint256,bytes[],address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "l2TransactionBaseCost" | "requestL2Transaction"): FunctionFragment;
    encodeFunctionData(functionFragment: "l2TransactionBaseCost", values: [BigNumberish, BigNumberish, BigNumberish]): string;
    encodeFunctionData(functionFragment: "requestL2Transaction", values: [
        string,
        BigNumberish,
        BytesLike,
        BigNumberish,
        BigNumberish,
        BytesLike[],
        string
    ]): string;
    decodeFunctionResult(functionFragment: "l2TransactionBaseCost", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "requestL2Transaction", data: BytesLike): Result;
    events: {};
}
export interface ZkSyncInterface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ZkSyncInterfaceInterface;
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
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<[BigNumber]>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
