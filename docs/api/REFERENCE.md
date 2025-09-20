# EigenLVR V2 API Reference

## Core Contract Interface

### EigenLVR_V2.sol

The main hook contract that implements Uniswap V4 hook functionality with LVR detection and private auction mechanisms.

#### Hook Functions

##### `beforeSwap(PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)`
- **Purpose**: Intercepts swap requests to detect LVR and trigger auctions
- **Parameters**:
  - `key`: Pool identification information
  - `params`: Swap parameters including amount and direction
  - `hookData`: Additional hook-specific data
- **Returns**: `(bytes4, BeforeSwapDelta)`
- **Events**: `AuctionStarted`, `EnhancedLVRDetected`

##### `afterSwap(PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata hookData)`
- **Purpose**: Post-swap processing for reward distribution
- **Parameters**:
  - `key`: Pool identification information
  - `params`: Swap parameters
  - `delta`: Balance changes from the swap
  - `hookData`: Additional hook-specific data
- **Returns**: `(bytes4, AfterSwapDelta)`
- **Events**: `MEVDistributed`, `RewardsClaimed`

##### `beforeAddLiquidity(PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData)`
- **Purpose**: Pre-liquidity addition processing
- **Parameters**:
  - `key`: Pool identification information
  - `params`: Liquidity modification parameters
  - `hookData`: Additional hook-specific data
- **Returns**: `(bytes4, BeforeModifyLiquidityDelta)`

##### `beforeRemoveLiquidity(PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData)`
- **Purpose**: Pre-liquidity removal processing
- **Parameters**:
  - `key`: Pool identification information
  - `params`: Liquidity modification parameters
  - `hookData`: Additional hook-specific data
- **Returns**: `(bytes4, BeforeModifyLiquidityDelta)`

##### `afterInitialize(PoolKey calldata key, uint160 sqrtPriceX96, int24 tick, bytes calldata hookData)`
- **Purpose**: Post-pool initialization processing
- **Parameters**:
  - `key`: Pool identification information
  - `sqrtPriceX96`: Initial pool price
  - `tick`: Initial tick
  - `hookData`: Additional hook-specific data
- **Returns**: `(bytes4, AfterInitializeDelta)`

#### Admin Functions

##### `setOperatorAuthorization(address operator, bool authorized)`
- **Purpose**: Authorize or deauthorize AVS operators
- **Access**: Owner only
- **Parameters**:
  - `operator`: Operator address to modify
  - `authorized`: Authorization status
- **Events**: `OperatorAuthorizationChanged`

##### `setLVRThreshold(uint256 newThreshold)`
- **Purpose**: Update LVR detection threshold
- **Access**: Owner only
- **Parameters**:
  - `newThreshold`: New threshold value (in basis points)
- **Events**: `LVRThresholdUpdated`

##### `pause()`
- **Purpose**: Pause contract operations
- **Access**: Owner only
- **Events**: `Paused`

##### `unpause()`
- **Purpose**: Resume contract operations
- **Access**: Owner only
- **Events**: `Unpaused`

#### View Functions

##### `getHookPermissions() external view returns (Hooks.Permissions memory)`
- **Purpose**: Get hook permission flags
- **Returns**: Hook permissions structure

##### `authorizedOperators(address operator) external view returns (bool)`
- **Purpose**: Check if operator is authorized
- **Parameters**:
  - `operator`: Operator address to check
- **Returns**: Authorization status

##### `lvrThreshold() external view returns (uint256)`
- **Purpose**: Get current LVR threshold
- **Returns**: Current threshold value

##### `paused() external view returns (bool)`
- **Purpose**: Check if contract is paused
- **Returns**: Pause status

### CrossChainPriceMonitor.sol

Cross-chain price monitoring and aggregation contract.

#### Core Functions

##### `updatePrice(Currency currency0, Currency currency1, uint256 price, uint256 timestamp)`
- **Purpose**: Update price for a currency pair
- **Access**: Authorized updaters only
- **Parameters**:
  - `currency0`: First currency
  - `currency1`: Second currency
  - `price`: Price value
  - `timestamp`: Price timestamp
- **Events**: `PriceUpdated`

##### `getBestPrice(Currency currency0, Currency currency1) external view returns (uint256)`
- **Purpose**: Get best available price for currency pair
- **Parameters**:
  - `currency0`: First currency
  - `currency1`: Second currency
- **Returns**: Best price value

##### `setAuthorizedUpdater(address updater, bool authorized)`
- **Purpose**: Authorize price updaters
- **Access**: Owner only
- **Parameters**:
  - `updater`: Updater address
  - `authorized`: Authorization status

### PrivateAuctionManager.sol

FHE-powered private auction management contract.

#### Core Functions

##### `createPrivateAuction(bytes32 auctionId, uint256 lvrAmount, bytes calldata encryptedParams)`
- **Purpose**: Create a private auction with encrypted parameters
- **Access**: Authorized operators only
- **Parameters**:
  - `auctionId`: Unique auction identifier
  - `lvrAmount`: LVR amount to auction
  - `encryptedParams`: FHE-encrypted auction parameters
- **Events**: `PrivateAuctionStarted`

##### `submitEncryptedBid(bytes32 auctionId, bytes calldata encryptedBid)`
- **Purpose**: Submit encrypted bid for private auction
- **Parameters**:
  - `auctionId`: Auction identifier
  - `encryptedBid`: FHE-encrypted bid data
- **Events**: `EncryptedBidSubmitted`

##### `revealBid(bytes32 auctionId, bytes calldata bidData, bytes calldata proof)`
- **Purpose**: Reveal bid after auction ends
- **Parameters**:
  - `auctionId`: Auction identifier
  - `bidData`: Decrypted bid data
  - `proof`: Bid validity proof
- **Events**: `BidRevealed`

##### `initializeFHE()`
- **Purpose**: Initialize FHE system
- **Access**: Authorized operators only
- **Events**: `FHEInitialized`

#### View Functions

##### `getAuctionStatus(bytes32 auctionId) external view returns (AuctionStatus)`
- **Purpose**: Get auction status
- **Parameters**:
  - `auctionId`: Auction identifier
- **Returns**: Auction status enum

##### `getAuctionResult(bytes32 auctionId) external view returns (AuctionResult memory)`
- **Purpose**: Get auction result
- **Parameters**:
  - `auctionId`: Auction identifier
- **Returns**: Auction result structure

### CrossChainLVRDetector.sol

Advanced LVR detection and analysis contract.

#### Core Functions

##### `detectLVR(PoolKey calldata key, SwapParams calldata params) external view returns (bool, uint256, bool)`
- **Purpose**: Detect LVR for a given swap
- **Parameters**:
  - `key`: Pool identification
  - `params`: Swap parameters
- **Returns**: `(hasLVR, lvrAmount, crossChainEnhanced)`

##### `calculateDeviation(uint256 poolPrice, uint256 oraclePrice) external pure returns (uint256)`
- **Purpose**: Calculate price deviation percentage
- **Parameters**:
  - `poolPrice`: Pool price
  - `oraclePrice`: Oracle price
- **Returns**: Deviation percentage in basis points

##### `isSignificantSwap(SwapParams calldata params) external pure returns (bool)`
- **Purpose**: Check if swap is significant enough for LVR detection
- **Parameters**:
  - `params`: Swap parameters
- **Returns**: Significance status

## Data Structures

### PoolKey
```solidity
struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}
```

### SwapParams
```solidity
struct SwapParams {
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
}
```

### AuctionResult
```solidity
struct AuctionResult {
    address winner;
    uint256 winningBid;
    uint256 lvrAmount;
    uint256 timestamp;
    bool isPrivate;
}
```

### AuctionStatus
```solidity
enum AuctionStatus {
    None,
    Active,
    Ended,
    Cancelled
}
```

## Events

### Core Events
- `AuctionStarted(bytes32 indexed auctionId, uint256 lvrAmount, bool isPrivate)`
- `AuctionEnded(bytes32 indexed auctionId, address winner, uint256 winningBid)`
- `MEVDistributed(uint256 lpReward, uint256 avsReward, uint256 protocolFee)`
- `RewardsClaimed(address indexed recipient, uint256 amount)`
- `EnhancedLVRDetected(uint256 deviation, uint256 lvrAmount)`

### Admin Events
- `OperatorAuthorizationChanged(address indexed operator, bool authorized)`
- `LVRThresholdUpdated(uint256 oldThreshold, uint256 newThreshold)`
- `Paused(address account)`
- `Unpaused(address account)`

### FHE Events
- `PrivateAuctionStarted(bytes32 indexed auctionId, bytes encryptedParams)`
- `EncryptedBidSubmitted(bytes32 indexed auctionId, address bidder)`
- `FHEInitialized(address indexed operator)`

## Error Codes

### Custom Errors
- `UnauthorizedOperator()`: Operator not authorized
- `InvalidThreshold()`: Invalid LVR threshold value
- `AuctionNotFound()`: Auction does not exist
- `AuctionEnded()`: Auction has already ended
- `InvalidEncryptedData()`: Invalid FHE encrypted data
- `PriceUpdateFailed()`: Price update operation failed

## Gas Costs

### Typical Gas Usage
- `beforeSwap`: ~37,000 gas
- `afterSwap`: ~21,000 gas
- `createPrivateAuction`: ~199,000 gas
- `detectLVR`: ~170,000 gas
- `setLVRThreshold`: ~19,000 gas

### Optimization Tips
- Use batch operations when possible
- Optimize hook data size
- Consider gas price for auction timing
- Use appropriate gas limits for FHE operations
