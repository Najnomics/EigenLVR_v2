import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface IPolygonZkEVMBridgeInterface extends utils.Interface {
    functions: {
        "bridgeAsset(uint32,address,uint256,address,bool,bytes)": FunctionFragment;
        "bridgeMessage(uint32,address,bool,bytes)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "bridgeAsset" | "bridgeMessage"): FunctionFragment;
    encodeFunctionData(functionFragment: "bridgeAsset", values: [BigNumberish, string, BigNumberish, string, boolean, BytesLike]): string;
    encodeFunctionData(functionFragment: "bridgeMessage", values: [BigNumberish, string, boolean, BytesLike]): string;
    decodeFunctionResult(functionFragment: "bridgeAsset", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "bridgeMessage", data: BytesLike): Result;
    events: {};
}
export interface IPolygonZkEVMBridge extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IPolygonZkEVMBridgeInterface;
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
        bridgeAsset(destinationNetwork: BigNumberish, destinationAddress: string, amount: BigNumberish, token: string, forceUpdateGlobalExitRoot: boolean, permitData: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        bridgeMessage(destinationNetwork: BigNumberish, destinationAddress: string, forceUpdateGlobalExitRoot: boolean, metadata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    bridgeAsset(destinationNetwork: BigNumberish, destinationAddress: string, amount: BigNumberish, token: string, forceUpdateGlobalExitRoot: boolean, permitData: BytesLike, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    bridgeMessage(destinationNetwork: BigNumberish, destinationAddress: string, forceUpdateGlobalExitRoot: boolean, metadata: BytesLike, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        bridgeAsset(destinationNetwork: BigNumberish, destinationAddress: string, amount: BigNumberish, token: string, forceUpdateGlobalExitRoot: boolean, permitData: BytesLike, overrides?: CallOverrides): Promise<void>;
        bridgeMessage(destinationNetwork: BigNumberish, destinationAddress: string, forceUpdateGlobalExitRoot: boolean, metadata: BytesLike, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        bridgeAsset(destinationNetwork: BigNumberish, destinationAddress: string, amount: BigNumberish, token: string, forceUpdateGlobalExitRoot: boolean, permitData: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        bridgeMessage(destinationNetwork: BigNumberish, destinationAddress: string, forceUpdateGlobalExitRoot: boolean, metadata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        bridgeAsset(destinationNetwork: BigNumberish, destinationAddress: string, amount: BigNumberish, token: string, forceUpdateGlobalExitRoot: boolean, permitData: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        bridgeMessage(destinationNetwork: BigNumberish, destinationAddress: string, forceUpdateGlobalExitRoot: boolean, metadata: BytesLike, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
