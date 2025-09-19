import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface LimitBypassProxyInterface extends utils.Interface {
    functions: {
        "deposit(address,address,uint256,uint256,uint256,address)": FunctionFragment;
        "l2TransactionBaseCost(uint256,uint256,uint256)": FunctionFragment;
        "requestL2Transaction(address,uint256,bytes,uint256,uint256,bytes[],address)": FunctionFragment;
        "zkErc20Bridge()": FunctionFragment;
        "zkSync()": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "deposit" | "l2TransactionBaseCost" | "requestL2Transaction" | "zkErc20Bridge" | "zkSync"): FunctionFragment;
    encodeFunctionData(functionFragment: "deposit", values: [string, string, BigNumberish, BigNumberish, BigNumberish, string]): string;
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
    encodeFunctionData(functionFragment: "zkErc20Bridge", values?: undefined): string;
    encodeFunctionData(functionFragment: "zkSync", values?: undefined): string;
    decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "l2TransactionBaseCost", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "requestL2Transaction", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "zkErc20Bridge", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "zkSync", data: BytesLike): Result;
    events: {};
}
export interface LimitBypassProxy extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: LimitBypassProxyInterface;
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
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<[BigNumber]>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        zkErc20Bridge(overrides?: CallOverrides): Promise<[string]>;
        zkSync(overrides?: CallOverrides): Promise<[string]>;
    };
    deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    zkErc20Bridge(overrides?: CallOverrides): Promise<string>;
    zkSync(overrides?: CallOverrides): Promise<string>;
    callStatic: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: CallOverrides): Promise<string>;
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: CallOverrides): Promise<string>;
        zkErc20Bridge(overrides?: CallOverrides): Promise<string>;
        zkSync(overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        zkErc20Bridge(overrides?: CallOverrides): Promise<BigNumber>;
        zkSync(overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        deposit(_l2Receiver: string, _l1Token: string, _amount: BigNumberish, _l2TxGasLimit: BigNumberish, _l2TxGasPerPubdataByte: BigNumberish, _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        l2TransactionBaseCost(_l1GasPrice: BigNumberish, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        requestL2Transaction(_contractL2: string, _l2Value: BigNumberish, _calldata: BytesLike, _l2GasLimit: BigNumberish, _l2GasPerPubdataByteLimit: BigNumberish, _factoryDeps: BytesLike[], _refundRecipient: string, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        zkErc20Bridge(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        zkSync(overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
