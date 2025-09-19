import type { BaseContract, BigNumber, BigNumberish, Signer, utils } from "ethers";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export declare namespace SpokePoolInterface {
    type RelayerRefundLeafStruct = {
        amountToReturn: BigNumberish;
        chainId: BigNumberish;
        refundAmounts: BigNumberish[];
        leafId: BigNumberish;
        l2TokenAddress: string;
        refundAddresses: string[];
    };
    type RelayerRefundLeafStructOutput = [
        BigNumber,
        BigNumber,
        BigNumber[],
        number,
        string,
        string[]
    ] & {
        amountToReturn: BigNumber;
        chainId: BigNumber;
        refundAmounts: BigNumber[];
        leafId: number;
        l2TokenAddress: string;
        refundAddresses: string[];
    };
}
export interface MockCallerInterface extends utils.Interface {
    functions: {};
    events: {};
}
export interface MockCaller extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: MockCallerInterface;
    queryFilter<TEvent extends TypedEvent>(event: TypedEventFilter<TEvent>, fromBlockOrBlockhash?: string | number | undefined, toBlock?: string | number | undefined): Promise<Array<TEvent>>;
    listeners<TEvent extends TypedEvent>(eventFilter?: TypedEventFilter<TEvent>): Array<TypedListener<TEvent>>;
    listeners(eventName?: string): Array<Listener>;
    removeAllListeners<TEvent extends TypedEvent>(eventFilter: TypedEventFilter<TEvent>): this;
    removeAllListeners(eventName?: string): this;
    off: OnEvent<this>;
    on: OnEvent<this>;
    once: OnEvent<this>;
    removeListener: OnEvent<this>;
    functions: {};
    callStatic: {};
    filters: {};
    estimateGas: {};
    populateTransaction: {};
}
