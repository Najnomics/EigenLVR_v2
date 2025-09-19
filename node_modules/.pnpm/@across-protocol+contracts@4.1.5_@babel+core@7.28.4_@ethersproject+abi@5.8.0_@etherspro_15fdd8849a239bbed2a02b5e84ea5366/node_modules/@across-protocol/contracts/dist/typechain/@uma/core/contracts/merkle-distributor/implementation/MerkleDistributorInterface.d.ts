import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../../../../common";
export declare namespace MerkleDistributorInterface {
    type ClaimStruct = {
        windowIndex: BigNumberish;
        amount: BigNumberish;
        accountIndex: BigNumberish;
        account: string;
        merkleProof: BytesLike[];
    };
    type ClaimStructOutput = [
        BigNumber,
        BigNumber,
        BigNumber,
        string,
        string[]
    ] & {
        windowIndex: BigNumber;
        amount: BigNumber;
        accountIndex: BigNumber;
        account: string;
        merkleProof: string[];
    };
}
export interface MerkleDistributorInterfaceInterface extends utils.Interface {
    functions: {
        "claim((uint256,uint256,uint256,address,bytes32[]))": FunctionFragment;
        "claimMulti((uint256,uint256,uint256,address,bytes32[])[])": FunctionFragment;
        "getRewardTokenForWindow(uint256)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "claim" | "claimMulti" | "getRewardTokenForWindow"): FunctionFragment;
    encodeFunctionData(functionFragment: "claim", values: [MerkleDistributorInterface.ClaimStruct]): string;
    encodeFunctionData(functionFragment: "claimMulti", values: [MerkleDistributorInterface.ClaimStruct[]]): string;
    encodeFunctionData(functionFragment: "getRewardTokenForWindow", values: [BigNumberish]): string;
    decodeFunctionResult(functionFragment: "claim", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "claimMulti", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "getRewardTokenForWindow", data: BytesLike): Result;
    events: {};
}
export interface MerkleDistributorInterface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: MerkleDistributorInterfaceInterface;
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
        claim(_claim: MerkleDistributorInterface.ClaimStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        claimMulti(claims: MerkleDistributorInterface.ClaimStruct[], overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        getRewardTokenForWindow(windowIndex: BigNumberish, overrides?: CallOverrides): Promise<[string]>;
    };
    claim(_claim: MerkleDistributorInterface.ClaimStruct, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    claimMulti(claims: MerkleDistributorInterface.ClaimStruct[], overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    getRewardTokenForWindow(windowIndex: BigNumberish, overrides?: CallOverrides): Promise<string>;
    callStatic: {
        claim(_claim: MerkleDistributorInterface.ClaimStruct, overrides?: CallOverrides): Promise<void>;
        claimMulti(claims: MerkleDistributorInterface.ClaimStruct[], overrides?: CallOverrides): Promise<void>;
        getRewardTokenForWindow(windowIndex: BigNumberish, overrides?: CallOverrides): Promise<string>;
    };
    filters: {};
    estimateGas: {
        claim(_claim: MerkleDistributorInterface.ClaimStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        claimMulti(claims: MerkleDistributorInterface.ClaimStruct[], overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        getRewardTokenForWindow(windowIndex: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
    };
    populateTransaction: {
        claim(_claim: MerkleDistributorInterface.ClaimStruct, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        claimMulti(claims: MerkleDistributorInterface.ClaimStruct[], overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        getRewardTokenForWindow(windowIndex: BigNumberish, overrides?: CallOverrides): Promise<PopulatedTransaction>;
    };
}
