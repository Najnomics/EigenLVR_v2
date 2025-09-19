import type { BaseContract, BigNumber, BigNumberish, BytesLike, CallOverrides, ContractTransaction, Overrides, PayableOverrides, PopulatedTransaction, Signer, utils } from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent } from "../../common";
export declare namespace HubPoolInterface {
    type RootBundleStruct = {
        poolRebalanceRoot: BytesLike;
        relayerRefundRoot: BytesLike;
        slowRelayRoot: BytesLike;
        claimedBitMap: BigNumberish;
        proposer: string;
        unclaimedPoolRebalanceLeafCount: BigNumberish;
        challengePeriodEndTimestamp: BigNumberish;
    };
    type RootBundleStructOutput = [
        string,
        string,
        string,
        BigNumber,
        string,
        number,
        number
    ] & {
        poolRebalanceRoot: string;
        relayerRefundRoot: string;
        slowRelayRoot: string;
        claimedBitMap: BigNumber;
        proposer: string;
        unclaimedPoolRebalanceLeafCount: number;
        challengePeriodEndTimestamp: number;
    };
}
export interface ExtendedHubPoolInterfaceInterface extends utils.Interface {
    functions: {
        "addLiquidity(address,uint256)": FunctionFragment;
        "claimProtocolFeesCaptured(address)": FunctionFragment;
        "disableL1TokenForLiquidityProvision(address)": FunctionFragment;
        "disputeRootBundle()": FunctionFragment;
        "emergencyDeleteProposal()": FunctionFragment;
        "enableL1TokenForLiquidityProvision(address)": FunctionFragment;
        "exchangeRateCurrent(address)": FunctionFragment;
        "executeRootBundle(uint256,uint256,uint256[],int256[],int256[],uint8,address[],bytes32[])": FunctionFragment;
        "liquidityUtilizationCurrent(address)": FunctionFragment;
        "liquidityUtilizationPostRelay(address,uint256)": FunctionFragment;
        "loadEthForL2Calls()": FunctionFragment;
        "poolRebalanceRoute(uint256,address)": FunctionFragment;
        "proposeRootBundle(uint256[],uint8,bytes32,bytes32,bytes32)": FunctionFragment;
        "relaySpokePoolAdminFunction(uint256,bytes)": FunctionFragment;
        "removeLiquidity(address,uint256,bool)": FunctionFragment;
        "rootBundleProposal()": FunctionFragment;
        "setBond(address,uint256)": FunctionFragment;
        "setCrossChainContracts(uint256,address,address)": FunctionFragment;
        "setDepositRoute(uint256,uint256,address,bool)": FunctionFragment;
        "setIdentifier(bytes32)": FunctionFragment;
        "setLiveness(uint32)": FunctionFragment;
        "setPaused(bool)": FunctionFragment;
        "setPoolRebalanceRoute(uint256,address,address)": FunctionFragment;
        "setProtocolFeeCapture(address,uint256)": FunctionFragment;
        "sync(address)": FunctionFragment;
    };
    getFunction(nameOrSignatureOrTopic: "addLiquidity" | "claimProtocolFeesCaptured" | "disableL1TokenForLiquidityProvision" | "disputeRootBundle" | "emergencyDeleteProposal" | "enableL1TokenForLiquidityProvision" | "exchangeRateCurrent" | "executeRootBundle" | "liquidityUtilizationCurrent" | "liquidityUtilizationPostRelay" | "loadEthForL2Calls" | "poolRebalanceRoute" | "proposeRootBundle" | "relaySpokePoolAdminFunction" | "removeLiquidity" | "rootBundleProposal" | "setBond" | "setCrossChainContracts" | "setDepositRoute" | "setIdentifier" | "setLiveness" | "setPaused" | "setPoolRebalanceRoute" | "setProtocolFeeCapture" | "sync"): FunctionFragment;
    encodeFunctionData(functionFragment: "addLiquidity", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "claimProtocolFeesCaptured", values: [string]): string;
    encodeFunctionData(functionFragment: "disableL1TokenForLiquidityProvision", values: [string]): string;
    encodeFunctionData(functionFragment: "disputeRootBundle", values?: undefined): string;
    encodeFunctionData(functionFragment: "emergencyDeleteProposal", values?: undefined): string;
    encodeFunctionData(functionFragment: "enableL1TokenForLiquidityProvision", values: [string]): string;
    encodeFunctionData(functionFragment: "exchangeRateCurrent", values: [string]): string;
    encodeFunctionData(functionFragment: "executeRootBundle", values: [
        BigNumberish,
        BigNumberish,
        BigNumberish[],
        BigNumberish[],
        BigNumberish[],
        BigNumberish,
        string[],
        BytesLike[]
    ]): string;
    encodeFunctionData(functionFragment: "liquidityUtilizationCurrent", values: [string]): string;
    encodeFunctionData(functionFragment: "liquidityUtilizationPostRelay", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "loadEthForL2Calls", values?: undefined): string;
    encodeFunctionData(functionFragment: "poolRebalanceRoute", values: [BigNumberish, string]): string;
    encodeFunctionData(functionFragment: "proposeRootBundle", values: [BigNumberish[], BigNumberish, BytesLike, BytesLike, BytesLike]): string;
    encodeFunctionData(functionFragment: "relaySpokePoolAdminFunction", values: [BigNumberish, BytesLike]): string;
    encodeFunctionData(functionFragment: "removeLiquidity", values: [string, BigNumberish, boolean]): string;
    encodeFunctionData(functionFragment: "rootBundleProposal", values?: undefined): string;
    encodeFunctionData(functionFragment: "setBond", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "setCrossChainContracts", values: [BigNumberish, string, string]): string;
    encodeFunctionData(functionFragment: "setDepositRoute", values: [BigNumberish, BigNumberish, string, boolean]): string;
    encodeFunctionData(functionFragment: "setIdentifier", values: [BytesLike]): string;
    encodeFunctionData(functionFragment: "setLiveness", values: [BigNumberish]): string;
    encodeFunctionData(functionFragment: "setPaused", values: [boolean]): string;
    encodeFunctionData(functionFragment: "setPoolRebalanceRoute", values: [BigNumberish, string, string]): string;
    encodeFunctionData(functionFragment: "setProtocolFeeCapture", values: [string, BigNumberish]): string;
    encodeFunctionData(functionFragment: "sync", values: [string]): string;
    decodeFunctionResult(functionFragment: "addLiquidity", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "claimProtocolFeesCaptured", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "disableL1TokenForLiquidityProvision", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "disputeRootBundle", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "emergencyDeleteProposal", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "enableL1TokenForLiquidityProvision", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "exchangeRateCurrent", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "executeRootBundle", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "liquidityUtilizationCurrent", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "liquidityUtilizationPostRelay", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "loadEthForL2Calls", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "poolRebalanceRoute", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "proposeRootBundle", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "relaySpokePoolAdminFunction", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "removeLiquidity", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "rootBundleProposal", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setBond", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setCrossChainContracts", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setDepositRoute", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setIdentifier", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setLiveness", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setPaused", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setPoolRebalanceRoute", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "setProtocolFeeCapture", data: BytesLike): Result;
    decodeFunctionResult(functionFragment: "sync", data: BytesLike): Result;
    events: {};
}
export interface ExtendedHubPoolInterface extends BaseContract {
    connect(signerOrProvider: Signer | Provider | string): this;
    attach(addressOrName: string): this;
    deployed(): Promise<this>;
    interface: ExtendedHubPoolInterfaceInterface;
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
        addLiquidity(l1Token: string, l1TokenAmount: BigNumberish, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        claimProtocolFeesCaptured(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        disableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        disputeRootBundle(overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        emergencyDeleteProposal(overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        enableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        exchangeRateCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        executeRootBundle(chainId: BigNumberish, groupIndex: BigNumberish, bundleLpFees: BigNumberish[], netSendAmounts: BigNumberish[], runningBalances: BigNumberish[], leafId: BigNumberish, l1Tokens: string[], proof: BytesLike[], overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        liquidityUtilizationCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        liquidityUtilizationPostRelay(l1Token: string, relayedAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        loadEthForL2Calls(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        poolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, overrides?: CallOverrides): Promise<[string] & {
            destinationToken: string;
        }>;
        proposeRootBundle(bundleEvaluationBlockNumbers: BigNumberish[], poolRebalanceLeafCount: BigNumberish, poolRebalanceRoot: BytesLike, relayerRefundRoot: BytesLike, slowRelayRoot: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        relaySpokePoolAdminFunction(chainId: BigNumberish, functionData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        removeLiquidity(l1Token: string, lpTokenAmount: BigNumberish, sendEth: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        rootBundleProposal(overrides?: CallOverrides): Promise<[HubPoolInterface.RootBundleStructOutput]>;
        setBond(newBondToken: string, newBondAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setCrossChainContracts(l2ChainId: BigNumberish, adapter: string, spokePool: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setDepositRoute(originChainId: BigNumberish, destinationChainId: BigNumberish, originToken: string, depositsEnabled: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setIdentifier(newIdentifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setLiveness(newLiveness: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setPaused(pause: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setPoolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, destinationToken: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        setProtocolFeeCapture(newProtocolFeeCaptureAddress: string, newProtocolFeeCapturePct: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
        sync(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<ContractTransaction>;
    };
    addLiquidity(l1Token: string, l1TokenAmount: BigNumberish, overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    claimProtocolFeesCaptured(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    disableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    disputeRootBundle(overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    emergencyDeleteProposal(overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    enableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    exchangeRateCurrent(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    executeRootBundle(chainId: BigNumberish, groupIndex: BigNumberish, bundleLpFees: BigNumberish[], netSendAmounts: BigNumberish[], runningBalances: BigNumberish[], leafId: BigNumberish, l1Tokens: string[], proof: BytesLike[], overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    liquidityUtilizationCurrent(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    liquidityUtilizationPostRelay(l1Token: string, relayedAmount: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    loadEthForL2Calls(overrides?: PayableOverrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    poolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, overrides?: CallOverrides): Promise<string>;
    proposeRootBundle(bundleEvaluationBlockNumbers: BigNumberish[], poolRebalanceLeafCount: BigNumberish, poolRebalanceRoot: BytesLike, relayerRefundRoot: BytesLike, slowRelayRoot: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    relaySpokePoolAdminFunction(chainId: BigNumberish, functionData: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    removeLiquidity(l1Token: string, lpTokenAmount: BigNumberish, sendEth: boolean, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    rootBundleProposal(overrides?: CallOverrides): Promise<HubPoolInterface.RootBundleStructOutput>;
    setBond(newBondToken: string, newBondAmount: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setCrossChainContracts(l2ChainId: BigNumberish, adapter: string, spokePool: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setDepositRoute(originChainId: BigNumberish, destinationChainId: BigNumberish, originToken: string, depositsEnabled: boolean, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setIdentifier(newIdentifier: BytesLike, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setLiveness(newLiveness: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setPaused(pause: boolean, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setPoolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, destinationToken: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    setProtocolFeeCapture(newProtocolFeeCaptureAddress: string, newProtocolFeeCapturePct: BigNumberish, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    sync(l1Token: string, overrides?: Overrides & {
        from?: string;
    }): Promise<ContractTransaction>;
    callStatic: {
        addLiquidity(l1Token: string, l1TokenAmount: BigNumberish, overrides?: CallOverrides): Promise<void>;
        claimProtocolFeesCaptured(l1Token: string, overrides?: CallOverrides): Promise<void>;
        disableL1TokenForLiquidityProvision(l1Token: string, overrides?: CallOverrides): Promise<void>;
        disputeRootBundle(overrides?: CallOverrides): Promise<void>;
        emergencyDeleteProposal(overrides?: CallOverrides): Promise<void>;
        enableL1TokenForLiquidityProvision(l1Token: string, overrides?: CallOverrides): Promise<void>;
        exchangeRateCurrent(l1Token: string, overrides?: CallOverrides): Promise<BigNumber>;
        executeRootBundle(chainId: BigNumberish, groupIndex: BigNumberish, bundleLpFees: BigNumberish[], netSendAmounts: BigNumberish[], runningBalances: BigNumberish[], leafId: BigNumberish, l1Tokens: string[], proof: BytesLike[], overrides?: CallOverrides): Promise<void>;
        liquidityUtilizationCurrent(l1Token: string, overrides?: CallOverrides): Promise<BigNumber>;
        liquidityUtilizationPostRelay(l1Token: string, relayedAmount: BigNumberish, overrides?: CallOverrides): Promise<BigNumber>;
        loadEthForL2Calls(overrides?: CallOverrides): Promise<void>;
        poolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, overrides?: CallOverrides): Promise<string>;
        proposeRootBundle(bundleEvaluationBlockNumbers: BigNumberish[], poolRebalanceLeafCount: BigNumberish, poolRebalanceRoot: BytesLike, relayerRefundRoot: BytesLike, slowRelayRoot: BytesLike, overrides?: CallOverrides): Promise<void>;
        relaySpokePoolAdminFunction(chainId: BigNumberish, functionData: BytesLike, overrides?: CallOverrides): Promise<void>;
        removeLiquidity(l1Token: string, lpTokenAmount: BigNumberish, sendEth: boolean, overrides?: CallOverrides): Promise<void>;
        rootBundleProposal(overrides?: CallOverrides): Promise<HubPoolInterface.RootBundleStructOutput>;
        setBond(newBondToken: string, newBondAmount: BigNumberish, overrides?: CallOverrides): Promise<void>;
        setCrossChainContracts(l2ChainId: BigNumberish, adapter: string, spokePool: string, overrides?: CallOverrides): Promise<void>;
        setDepositRoute(originChainId: BigNumberish, destinationChainId: BigNumberish, originToken: string, depositsEnabled: boolean, overrides?: CallOverrides): Promise<void>;
        setIdentifier(newIdentifier: BytesLike, overrides?: CallOverrides): Promise<void>;
        setLiveness(newLiveness: BigNumberish, overrides?: CallOverrides): Promise<void>;
        setPaused(pause: boolean, overrides?: CallOverrides): Promise<void>;
        setPoolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, destinationToken: string, overrides?: CallOverrides): Promise<void>;
        setProtocolFeeCapture(newProtocolFeeCaptureAddress: string, newProtocolFeeCapturePct: BigNumberish, overrides?: CallOverrides): Promise<void>;
        sync(l1Token: string, overrides?: CallOverrides): Promise<void>;
    };
    filters: {};
    estimateGas: {
        addLiquidity(l1Token: string, l1TokenAmount: BigNumberish, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        claimProtocolFeesCaptured(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        disableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        disputeRootBundle(overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        emergencyDeleteProposal(overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        enableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        exchangeRateCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        executeRootBundle(chainId: BigNumberish, groupIndex: BigNumberish, bundleLpFees: BigNumberish[], netSendAmounts: BigNumberish[], runningBalances: BigNumberish[], leafId: BigNumberish, l1Tokens: string[], proof: BytesLike[], overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        liquidityUtilizationCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        liquidityUtilizationPostRelay(l1Token: string, relayedAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        loadEthForL2Calls(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<BigNumber>;
        poolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, overrides?: CallOverrides): Promise<BigNumber>;
        proposeRootBundle(bundleEvaluationBlockNumbers: BigNumberish[], poolRebalanceLeafCount: BigNumberish, poolRebalanceRoot: BytesLike, relayerRefundRoot: BytesLike, slowRelayRoot: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        relaySpokePoolAdminFunction(chainId: BigNumberish, functionData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        removeLiquidity(l1Token: string, lpTokenAmount: BigNumberish, sendEth: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        rootBundleProposal(overrides?: CallOverrides): Promise<BigNumber>;
        setBond(newBondToken: string, newBondAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setCrossChainContracts(l2ChainId: BigNumberish, adapter: string, spokePool: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setDepositRoute(originChainId: BigNumberish, destinationChainId: BigNumberish, originToken: string, depositsEnabled: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setIdentifier(newIdentifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setLiveness(newLiveness: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setPaused(pause: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setPoolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, destinationToken: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        setProtocolFeeCapture(newProtocolFeeCaptureAddress: string, newProtocolFeeCapturePct: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
        sync(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<BigNumber>;
    };
    populateTransaction: {
        addLiquidity(l1Token: string, l1TokenAmount: BigNumberish, overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        claimProtocolFeesCaptured(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        disableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        disputeRootBundle(overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        emergencyDeleteProposal(overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        enableL1TokenForLiquidityProvision(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        exchangeRateCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        executeRootBundle(chainId: BigNumberish, groupIndex: BigNumberish, bundleLpFees: BigNumberish[], netSendAmounts: BigNumberish[], runningBalances: BigNumberish[], leafId: BigNumberish, l1Tokens: string[], proof: BytesLike[], overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        liquidityUtilizationCurrent(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        liquidityUtilizationPostRelay(l1Token: string, relayedAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        loadEthForL2Calls(overrides?: PayableOverrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        poolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, overrides?: CallOverrides): Promise<PopulatedTransaction>;
        proposeRootBundle(bundleEvaluationBlockNumbers: BigNumberish[], poolRebalanceLeafCount: BigNumberish, poolRebalanceRoot: BytesLike, relayerRefundRoot: BytesLike, slowRelayRoot: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        relaySpokePoolAdminFunction(chainId: BigNumberish, functionData: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        removeLiquidity(l1Token: string, lpTokenAmount: BigNumberish, sendEth: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        rootBundleProposal(overrides?: CallOverrides): Promise<PopulatedTransaction>;
        setBond(newBondToken: string, newBondAmount: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setCrossChainContracts(l2ChainId: BigNumberish, adapter: string, spokePool: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setDepositRoute(originChainId: BigNumberish, destinationChainId: BigNumberish, originToken: string, depositsEnabled: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setIdentifier(newIdentifier: BytesLike, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setLiveness(newLiveness: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setPaused(pause: boolean, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setPoolRebalanceRoute(destinationChainId: BigNumberish, l1Token: string, destinationToken: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        setProtocolFeeCapture(newProtocolFeeCaptureAddress: string, newProtocolFeeCapturePct: BigNumberish, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
        sync(l1Token: string, overrides?: Overrides & {
            from?: string;
        }): Promise<PopulatedTransaction>;
    };
}
