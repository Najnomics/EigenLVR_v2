# EigenLVR v2 API Documentation

## Overview

This document provides comprehensive API documentation for EigenLVR v2, including smart contract interfaces, REST API endpoints, and integration examples.

## Smart Contract APIs

### EigenLVR_V2 Hook Contract

#### Core Functions

##### `beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)`
Executes before a swap to detect LVR opportunities and trigger auctions.

**Parameters:**
- `sender`: Address of the swap initiator
- `key`: Pool key containing currency pair and fee information
- `params`: Swap parameters including amount and direction
- `hookData`: Additional data for private auction requests

**Returns:**
- `bytes4`: Function selector
- `BeforeSwapDelta`: Delta to apply to the swap
- `uint24`: Additional fee to charge

**Events:**
```solidity
event AuctionStarted(bytes32 indexed auctionId, PoolId indexed poolId, uint256 lvrAmount, uint256 duration, bool isPrivate);
event LVRDetected(PoolId indexed poolId, uint256 deviation, uint256 volume);
```

##### `afterSwap(address sender, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata hookData)`
Executes after a swap to process completed auctions and distribute MEV.

**Parameters:**
- `sender`: Address of the swap initiator
- `key`: Pool key containing currency pair and fee information
- `params`: Swap parameters including amount and direction
- `delta`: Balance delta from the swap
- `hookData`: Additional data for processing

**Returns:**
- `bytes4`: Function selector

**Events:**
```solidity
event AuctionCompleted(bytes32 indexed auctionId, address indexed winner, uint256 winningBid);
event MEVDistributed(PoolId indexed poolId, uint256 totalAmount, uint256 lpReward, uint256 avsReward);
```

##### `beforeAddLiquidity(address sender, PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData)`
Tracks liquidity provider positions when adding liquidity.

**Parameters:**
- `sender`: Address of the liquidity provider
- `key`: Pool key containing currency pair and fee information
- `params`: Liquidity modification parameters
- `hookData`: Additional data for processing

**Returns:**
- `bytes4`: Function selector

**Events:**
```solidity
event LiquidityAdded(PoolId indexed poolId, address indexed provider, uint256 amount);
```

##### `beforeRemoveLiquidity(address sender, PoolKey calldata key, ModifyLiquidityParams calldata params, bytes calldata hookData)`
Updates liquidity tracking when removing liquidity.

**Parameters:**
- `sender`: Address of the liquidity provider
- `key`: Pool key containing currency pair and fee information
- `params`: Liquidity modification parameters
- `hookData`: Additional data for processing

**Returns:**
- `bytes4`: Function selector

**Events:**
```solidity
event LiquidityRemoved(PoolId indexed poolId, address indexed provider, uint256 amount);
```

#### View Functions

##### `getHookPermissions() external pure returns (Hooks.Permissions memory)`
Returns the hook permissions for Uniswap V4 integration.

**Returns:**
```solidity
Hooks.Permissions({
    beforeInitialize: false,
    afterInitialize: true,
    beforeAddLiquidity: true,
    afterAddLiquidity: false,
    beforeRemoveLiquidity: true,
    afterRemoveLiquidity: false,
    beforeSwap: true,
    afterSwap: true,
    beforeDonate: false,
    afterDonate: false,
    beforeSwapReturnDelta: false,
    afterSwapReturnDelta: false,
    afterAddLiquidityReturnDelta: false,
    afterRemoveLiquidityReturnDelta: false
})
```

##### `getAuction(bytes32 auctionId) external view returns (AuctionLib.Auction memory)`
Returns auction information by auction ID.

**Parameters:**
- `auctionId`: Unique identifier for the auction

**Returns:**
```solidity
struct Auction {
    PoolId poolId;
    uint256 startTime;
    uint256 duration;
    uint256 minBid;
    uint256 reservePrice;
    uint256 highestBid;
    address highestBidder;
    bool isComplete;
    bool isPrivate;
}
```

##### `getLiquidityProviderReward(PoolId poolId, address provider) external view returns (uint256)`
Returns the pending reward for a liquidity provider.

**Parameters:**
- `poolId`: Pool identifier
- `provider`: Liquidity provider address

**Returns:**
- `uint256`: Pending reward amount

##### `getPoolRewards(PoolId poolId) external view returns (uint256)`
Returns the total rewards accumulated for a pool.

**Parameters:**
- `poolId`: Pool identifier

**Returns:**
- `uint256`: Total pool rewards

#### Admin Functions

##### `setLVRThreshold(uint256 threshold) external onlyOwner`
Sets the LVR detection threshold in basis points.

**Parameters:**
- `threshold`: New threshold value (0-1000 basis points)

**Requirements:**
- Caller must be the owner
- Threshold must be <= 1000

##### `setOperatorAuthorization(address operator, bool authorized) external onlyOwner`
Authorizes or deauthorizes an operator.

**Parameters:**
- `operator`: Operator address
- `authorized`: Authorization status

**Requirements:**
- Caller must be the owner

##### `pause() external onlyOwner`
Pauses the contract.

**Requirements:**
- Caller must be the owner
- Contract must not already be paused

##### `unpause() external onlyOwner`
Unpauses the contract.

**Requirements:**
- Caller must be the owner
- Contract must be paused

### Cross-Chain Components

#### CrossChainPriceMonitor Contract

##### `getBestPrice(address token0, address token1) external view returns (uint256)`
Returns the best price across all supported chains.

**Parameters:**
- `token0`: First token address
- `token1`: Second token address

**Returns:**
- `uint256`: Best price found

##### `setChainPrice(uint256 chainId, address token0, address token1, uint256 price) external onlyOperator`
Sets the price for a specific chain.

**Parameters:**
- `chainId`: Chain identifier
- `token0`: First token address
- `token1`: Second token address
- `price`: Price value

**Requirements:**
- Caller must be authorized operator

#### CrossChainLVRDetector Contract

##### `detectCrossChainOpportunity(address token0, address token1) external view returns (CrossChainOpportunity memory)`
Detects cross-chain arbitrage opportunities.

**Parameters:**
- `token0`: First token address
- `token1`: Second token address

**Returns:**
```solidity
struct CrossChainOpportunity {
    uint256 sourceChain;
    uint256 targetChain;
    uint256 profitBps;
    uint256 volume;
    bool isActive;
    uint256 deadline;
}
```

### Privacy Components

#### PrivateAuctionManager Contract

##### `createPrivateAuction(bytes32 auctionId, uint256 minBid, uint256 reservePrice, uint256 duration) external`
Creates a new private auction with FHE encryption.

**Parameters:**
- `auctionId`: Unique auction identifier
- `minBid`: Minimum bid amount
- `reservePrice`: Reserve price for the auction
- `duration`: Auction duration in seconds

**Requirements:**
- Caller must be authorized
- Auction ID must not already exist

##### `submitPrivateBid(bytes32 auctionId, bytes calldata encryptedBid, bytes calldata commitment) external`
Submits an encrypted bid to a private auction.

**Parameters:**
- `auctionId`: Auction identifier
- `encryptedBid`: Encrypted bid data
- `commitment`: Bid commitment for verification

**Requirements:**
- Auction must be active
- Bid must be properly encrypted

##### `revealAuctionWinner(bytes32 auctionId) external onlyOperator`
Reveals the winner of a private auction.

**Parameters:**
- `auctionId`: Auction identifier

**Requirements:**
- Caller must be authorized operator
- Auction must be completed

## REST API Endpoints

### Base URL
```
https://api.eigenlvr.com/v1
```

### Authentication
All API requests require authentication using an API key:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" https://api.eigenlvr.com/v1/...
```

### Endpoints

#### GET /pools
Returns information about all supported pools.

**Response:**
```json
{
  "pools": [
    {
      "poolId": "0x...",
      "token0": "0x...",
      "token1": "0x...",
      "fee": 3000,
      "tickSpacing": 60,
      "totalLiquidity": "1000000000000000000000",
      "activeAuctions": 2
    }
  ]
}
```

#### GET /pools/{poolId}
Returns detailed information about a specific pool.

**Parameters:**
- `poolId`: Pool identifier

**Response:**
```json
{
  "poolId": "0x...",
  "token0": {
    "address": "0x...",
    "symbol": "ETH",
    "decimals": 18
  },
  "token1": {
    "address": "0x...",
    "symbol": "USDC",
    "decimals": 6
  },
  "fee": 3000,
  "tickSpacing": 60,
  "totalLiquidity": "1000000000000000000000",
  "lpCount": 150,
  "activeAuctions": 2,
  "totalMEVDistributed": "50000000000000000000"
}
```

#### GET /pools/{poolId}/auctions
Returns auctions for a specific pool.

**Parameters:**
- `poolId`: Pool identifier
- `status`: Filter by auction status (active, completed, cancelled)
- `limit`: Maximum number of results (default: 50)
- `offset`: Number of results to skip (default: 0)

**Response:**
```json
{
  "auctions": [
    {
      "auctionId": "0x...",
      "poolId": "0x...",
      "startTime": 1700000000,
      "duration": 3600,
      "minBid": "1000000000000000000",
      "reservePrice": "1100000000000000000",
      "highestBid": "1500000000000000000",
      "highestBidder": "0x...",
      "isComplete": false,
      "isPrivate": true,
      "bidCount": 5
    }
  ],
  "total": 25,
  "limit": 50,
  "offset": 0
}
```

#### GET /auctions/{auctionId}
Returns detailed information about a specific auction.

**Parameters:**
- `auctionId`: Auction identifier

**Response:**
```json
{
  "auctionId": "0x...",
  "poolId": "0x...",
  "startTime": 1700000000,
  "duration": 3600,
  "minBid": "1000000000000000000",
  "reservePrice": "1100000000000000000",
  "highestBid": "1500000000000000000",
  "highestBidder": "0x...",
  "isComplete": false,
  "isPrivate": true,
  "bidCount": 5,
  "bids": [
    {
      "bidder": "0x...",
      "amount": "1500000000000000000",
      "timestamp": 1700001000,
      "isWinning": true
    }
  ]
}
```

#### GET /liquidity-providers/{address}
Returns information about a liquidity provider.

**Parameters:**
- `address`: Liquidity provider address

**Response:**
```json
{
  "address": "0x...",
  "totalLiquidity": "1000000000000000000000",
  "activePools": 5,
  "totalRewards": "50000000000000000000",
  "pendingRewards": "10000000000000000000",
  "pools": [
    {
      "poolId": "0x...",
      "liquidity": "200000000000000000000",
      "rewards": "10000000000000000000",
      "percentage": 20
    }
  ]
}
```

#### GET /cross-chain/opportunities
Returns cross-chain arbitrage opportunities.

**Parameters:**
- `token0`: First token address
- `token1`: Second token address
- `minProfitBps`: Minimum profit in basis points
- `limit`: Maximum number of results

**Response:**
```json
{
  "opportunities": [
    {
      "sourceChain": 1,
      "targetChain": 42161,
      "token0": "0x...",
      "token1": "0x...",
      "profitBps": 50,
      "volume": "1000000000000000000000",
      "isActive": true,
      "deadline": 1700003600
    }
  ]
}
```

#### GET /metrics
Returns system metrics and statistics.

**Response:**
```json
{
  "totalMEVDistributed": "1000000000000000000000",
  "totalAuctions": 5000,
  "activeAuctions": 25,
  "totalLiquidity": "100000000000000000000000",
  "activePools": 50,
  "crossChainOpportunities": 10,
  "averageAuctionDuration": 1800,
  "successRate": 0.95
}
```

## Integration Examples

### JavaScript/TypeScript

#### Basic Integration
```typescript
import { ethers } from 'ethers';
import { EigenLVR_V2__factory } from './contracts';

// Initialize provider and signer
const provider = new ethers.providers.JsonRpcProvider('https://mainnet.infura.io/v3/YOUR_KEY');
const signer = new ethers.Wallet('YOUR_PRIVATE_KEY', provider);

// Initialize contract
const eigenLVR = EigenLVR_V2__factory.connect('CONTRACT_ADDRESS', signer);

// Check hook permissions
const permissions = await eigenLVR.getHookPermissions();
console.log('Hook permissions:', permissions);

// Get pool information
const poolId = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(
  ['address', 'address', 'uint24', 'int24'],
  ['TOKEN0_ADDRESS', 'TOKEN1_ADDRESS', 3000, 60]
));

const activeAuction = await eigenLVR.activeAuctions(poolId);
console.log('Active auction:', activeAuction);
```

#### Auction Monitoring
```typescript
// Monitor auction events
eigenLVR.on('AuctionStarted', (auctionId, poolId, lvrAmount, duration, isPrivate) => {
  console.log('New auction started:', {
    auctionId,
    poolId,
    lvrAmount: ethers.utils.formatEther(lvrAmount),
    duration,
    isPrivate
  });
});

eigenLVR.on('AuctionCompleted', (auctionId, winner, winningBid) => {
  console.log('Auction completed:', {
    auctionId,
    winner,
    winningBid: ethers.utils.formatEther(winningBid)
  });
});
```

#### Cross-Chain Integration
```typescript
import { CrossChainPriceMonitor__factory } from './contracts';

const crossChainMonitor = CrossChainPriceMonitor__factory.connect('CROSS_CHAIN_ADDRESS', signer);

// Get best price across chains
const bestPrice = await crossChainMonitor.getBestPrice('TOKEN0_ADDRESS', 'TOKEN1_ADDRESS');
console.log('Best price:', ethers.utils.formatEther(bestPrice));

// Monitor cross-chain opportunities
const opportunities = await fetch('/api/v1/cross-chain/opportunities?token0=TOKEN0_ADDRESS&token1=TOKEN1_ADDRESS');
const data = await opportunities.json();
console.log('Cross-chain opportunities:', data.opportunities);
```

### Python

#### Basic Integration
```python
from web3 import Web3
from eth_abi import encode
import json

# Initialize Web3
w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_KEY'))

# Load contract ABI
with open('EigenLVR_V2.json', 'r') as f:
    abi = json.load(f)

# Initialize contract
contract = w3.eth.contract(address='CONTRACT_ADDRESS', abi=abi)

# Check hook permissions
permissions = contract.functions.getHookPermissions().call()
print('Hook permissions:', permissions)

# Get pool information
pool_id = Web3.keccak(encode(['address', 'address', 'uint24', 'int24'], 
                            ['TOKEN0_ADDRESS', 'TOKEN1_ADDRESS', 3000, 60]))

active_auction = contract.functions.activeAuctions(pool_id).call()
print('Active auction:', active_auction)
```

#### Event Monitoring
```python
# Monitor auction events
def handle_auction_started(event):
    print('New auction started:', {
        'auctionId': event['args']['auctionId'].hex(),
        'poolId': event['args']['poolId'].hex(),
        'lvrAmount': Web3.fromWei(event['args']['lvrAmount'], 'ether'),
        'duration': event['args']['duration'],
        'isPrivate': event['args']['isPrivate']
    })

# Set up event filter
auction_filter = contract.events.AuctionStarted.createFilter(fromBlock='latest')
auction_filter.watch(handle_auction_started)
```

### Go (AVS Integration)

#### Operator Implementation
```go
package main

import (
    "context"
    "log"
    "time"
    
    "github.com/ethereum/go-ethereum/ethclient"
    "github.com/ethereum/go-ethereum/accounts/abi/bind"
)

type EigenLVROperator struct {
    client     *ethclient.Client
    contract   *EigenLVR_V2
    privateKey *ecdsa.PrivateKey
}

func (op *EigenLVROperator) Start() error {
    // Initialize Ethereum client
    client, err := ethclient.Dial("https://mainnet.infura.io/v3/YOUR_KEY")
    if err != nil {
        return err
    }
    
    // Initialize contract
    contract, err := NewEigenLVR_V2(common.HexToAddress("CONTRACT_ADDRESS"), client)
    if err != nil {
        return err
    }
    
    op.client = client
    op.contract = contract
    
    // Start monitoring
    go op.monitorAuctions()
    go op.processCrossChainOpportunities()
    
    return nil
}

func (op *EigenLVROperator) monitorAuctions() {
    // Monitor auction events
    auctionFilter, err := op.contract.FilterAuctionStarted(nil, nil, nil, nil, nil)
    if err != nil {
        log.Fatal(err)
    }
    
    for {
        select {
        case event := <-auctionFilter.Event:
            log.Printf("New auction started: %s", event.AuctionId.Hex())
            // Process auction
            go op.processAuction(event.AuctionId)
        }
    }
}
```

## Error Handling

### Common Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Bad Request | Invalid request parameters |
| 401 | Unauthorized | Missing or invalid API key |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### Smart Contract Errors

| Error | Description |
|-------|-------------|
| `NotPoolManager()` | Caller is not the pool manager |
| `Pausable: paused` | Contract is paused |
| `Threshold too high` | LVR threshold exceeds maximum |
| `Auction not active` | Auction is not active |
| `Auction ended` | Auction has ended |

## Rate Limits

- **API Requests**: 1000 requests per hour per API key
- **WebSocket Connections**: 10 concurrent connections per API key
- **Event Subscriptions**: 50 active subscriptions per connection

## Support

For API support:
- **Documentation**: [https://docs.eigenlvr.com/api](https://docs.eigenlvr.com/api)
- **Discord**: [EigenLVR Community](https://discord.gg/eigenlvr)
- **GitHub Issues**: [Report Issues](https://github.com/Najnomics/EigenLVR_v2/issues)
