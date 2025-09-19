import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../common";
export interface IL1ERC20BridgeInterface extends utils.Interface {
    functions: {
        "bridgeERC20To(address,address,address,uint256,uint32,bytes)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "bridgeERC20To"): FunctionFragment;
    encodeFunctionData(functionFragment: "bridgeERC20To", values: [string, string, string, BigNumberish, BigNumberish, BytesLike]): string;
    decodeFunctionResult(functionFragment: "bridgeERC20To", data: BytesLike): Result;
    events: {};
}
export interface IL1ERC20Bridge extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: IL1ERC20BridgeInterface;
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
        bridgeERC20To(_localToken: string, _remoteToken: string, _to: string, _amount: BigNumberish, _minGasLimit: BigNumberish, _extraData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    bridgeERC20To(_localToken: string, _remoteToken: string, _to: string, _amount: BigNumberish, _minGasLimit: BigNumberish, _extraData: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        bridgeERC20To(_localToken: string, _remoteToken: string, _to: string, _amount: BigNumberish, _minGasLimit: BigNumberish, _extraData: BytesLike, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        bridgeERC20To(_localToken: string, _remoteToken: string, _to: string, _amount: BigNumberish, _minGasLimit: BigNumberish, _extraData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        bridgeERC20To(_localToken: string, _remoteToken: string, _to: string, _amount: BigNumberish, _minGasLimit: BigNumberish, _extraData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
