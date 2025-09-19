import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface ArbitrumMockErc20GatewayRouterInterface extends utils.Interface {
    functions: {
        "getGateway(address)": FunctionFragment;
        "outboundTransfer(address,address,uint256,uint256,uint256,bytes)": FunctionFragment;
        "outboundTransferCustomRefund(address,address,address,uint256,uint256,uint256,bytes)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "getGateway" | "outboundTransfer" | "outboundTransferCustomRefund"): FunctionFragment;
    encodeFunctionData(functionFragment: "getGateway", values: [string]): string;
    encodeFunctionData(functionFragment: "outboundTransfer", values: [
        string,
        string,
        BigNumberish,
        BigNumberish,
        BigNumberish,
        BytesLike
    ]): string;
    encodeFunctionData(functionFragment: "outboundTransferCustomRefund", values: [
        string,
        string,
        string,
        BigNumberish,
        BigNumberish,
        BigNumberish,
        BytesLike
    ]): string;
    decodeFunctionResult(functionFragment: "getGateway", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "outboundTransfer", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "outboundTransferCustomRefund", data: BytesLike): Result;
    events: {};
}
export interface ArbitrumMockErc20GatewayRouter extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ArbitrumMockErc20GatewayRouterInterface;
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
        getGateway(arg0: string, overrides?: CallOverrides): Promise<[string]>;
        outboundTransfer(arg0: string, arg1: string, arg2: BigNumberish, arg3: BigNumberish, arg4: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        outboundTransferCustomRefund(arg0: string, arg1: string, arg2: string, arg3: BigNumberish, arg4: BigNumberish, arg5: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    getGateway(arg0: string, overrides?: CallOverrides): Promise<string>;
    outboundTransfer(arg0: string, arg1: string, arg2: BigNumberish, arg3: BigNumberish, arg4: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    outboundTransferCustomRefund(arg0: string, arg1: string, arg2: string, arg3: BigNumberish, arg4: BigNumberish, arg5: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        getGateway(arg0: string, overrides?: CallOverrides): Promise<string>;
        outboundTransfer(arg0: string, arg1: string, arg2: BigNumberish, arg3: BigNumberish, arg4: BigNumberish, _data: BytesLike, overrides?: CallOverrides): Promise<string>;
        outboundTransferCustomRefund(arg0: string, arg1: string, arg2: string, arg3: BigNumberish, arg4: BigNumberish, arg5: BigNumberish, _data: BytesLike, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        getGateway(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;
        outboundTransfer(arg0: string, arg1: string, arg2: BigNumberish, arg3: BigNumberish, arg4: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        outboundTransferCustomRefund(arg0: string, arg1: string, arg2: string, arg3: BigNumberish, arg4: BigNumberish, arg5: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        getGateway(arg0: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        outboundTransfer(arg0: string, arg1: string, arg2: BigNumberish, arg3: BigNumberish, arg4: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        outboundTransferCustomRefund(arg0: string, arg1: string, arg2: string, arg3: BigNumberish, arg4: BigNumberish, arg5: BigNumberish, _data: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
