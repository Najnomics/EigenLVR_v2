# EigenLVR V2 Deployment Guide

## Prerequisites

### Required Software
- [Foundry](https://getfoundry.sh/) (latest version)
- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)

### Required Accounts & Services
- Ethereum wallet with sufficient ETH for deployment
- [Infura](https://infura.io/) or [Alchemy](https://alchemy.com/) API key
- [Etherscan](https://etherscan.io/) API key for contract verification
- [EigenLayer](https://eigenlayer.xyz/) operator account (for AVS integration)
- [Fhenix](https://fhenix.io/) account (for FHE integration)

### Environment Setup
```bash
# Clone repository
git clone https://github.com/your-org/EigenLVR_v2.git
cd EigenLVR_v2

# Install dependencies
forge install
npm install

# Copy environment file
cp .env.example .env
# Edit .env with your configuration
```

## Deployment Steps

### 1. Local Development (Anvil)

#### Start Local Node
```bash
# Start Anvil with specific configuration
anvil --chain-id 31337 --gas-limit 30000000
```

#### Deploy Contracts
```bash
# Deploy to local network
forge script script/DeployEnhanced.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

#### Verify Deployment
```bash
# Run tests against deployed contracts
forge test --fork-url http://localhost:8545
```

### 2. Testnet Deployment (Sepolia)

#### Prepare Environment
```bash
# Set environment variables
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_PROJECT_ID"
export SEPOLIA_PRIVATE_KEY="your_private_key_here"
export SEPOLIA_ETHERSCAN_API_KEY="your_etherscan_api_key_here"
```

#### Deploy Contracts
```bash
# Deploy to Sepolia testnet
forge script script/DeployEnhanced.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $SEPOLIA_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $SEPOLIA_ETHERSCAN_API_KEY \
  --slow
```

#### Post-Deployment Setup
```bash
# Set up initial configuration
cast send $HOOK_ADDRESS "setLVRThreshold(uint256)" 50 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $SEPOLIA_PRIVATE_KEY

# Authorize operators
cast send $HOOK_ADDRESS "setOperatorAuthorization(address,bool)" $OPERATOR_ADDRESS true \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $SEPOLIA_PRIVATE_KEY
```

### 3. Mainnet Deployment

#### Pre-Deployment Checklist
- [ ] All tests passing (`forge test`)
- [ ] Security audit completed
- [ ] Gas optimization verified
- [ ] Environment variables configured
- [ ] Multi-sig wallet prepared
- [ ] Emergency procedures documented

#### Deploy Contracts
```bash
# Deploy to Ethereum mainnet
forge script script/DeployEnhanced.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $MAINNET_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $MAINNET_ETHERSCAN_API_KEY \
  --slow
```

#### Post-Deployment Configuration
```bash
# Transfer ownership to multi-sig
cast send $HOOK_ADDRESS "transferOwnership(address)" $MULTISIG_ADDRESS \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $MAINNET_PRIVATE_KEY

# Set up initial parameters
cast send $HOOK_ADDRESS "setLVRThreshold(uint256)" 50 \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $MULTISIG_PRIVATE_KEY
```

## Contract Addresses

### Deployment Script Output
The deployment script will output contract addresses in the following format:

```
EigenLVR_V2 deployed at: 0x...
CrossChainPriceMonitor deployed at: 0x...
PrivateAuctionManager deployed at: 0x...
CrossChainLVRDetector deployed at: 0x...
```

### Address Management
Store all contract addresses securely:
- Main contract: EigenLVR_V2
- Price monitor: CrossChainPriceMonitor
- Auction manager: PrivateAuctionManager
- LVR detector: CrossChainLVRDetector

## Integration Setup

### 1. EigenLayer AVS Integration

#### Register as AVS Operator
```bash
# Register with EigenLayer AVS Directory
cast send $AVS_DIRECTORY "registerOperatorToAVS(bytes)" $SIGNATURE \
  --rpc-url $RPC_URL \
  --private-key $OPERATOR_PRIVATE_KEY
```

#### Configure AVS Parameters
```bash
# Set AVS-specific parameters
cast send $HOOK_ADDRESS "setAVSParameters(address,uint256)" $AVS_ADDRESS $STAKE_AMOUNT \
  --rpc-url $RPC_URL \
  --private-key $OPERATOR_PRIVATE_KEY
```

### 2. Fhenix Protocol Integration

#### Initialize FHE System
```bash
# Initialize CoFHE contracts
cast send $PRIVATE_AUCTION_MANAGER "initializeFHE()" \
  --rpc-url $FHENIX_RPC_URL \
  --private-key $OPERATOR_PRIVATE_KEY
```

#### Configure FHE Parameters
```bash
# Set FHE-specific parameters
cast send $PRIVATE_AUCTION_MANAGER "setFHEParameters(bytes,bytes)" $PUBLIC_KEY $PRIVATE_KEY \
  --rpc-url $FHENIX_RPC_URL \
  --private-key $OPERATOR_PRIVATE_KEY
```

### 3. Price Oracle Integration

#### Configure Price Sources
```bash
# Set Chainlink oracle addresses
cast send $PRICE_MONITOR "setOracleAddress(address,address)" $CHAINLINK_ETH_USD $CHAINLINK_BTC_USD \
  --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY
```

#### Authorize Price Updaters
```bash
# Authorize price update sources
cast send $PRICE_MONITOR "setAuthorizedUpdater(address,bool)" $PRICE_UPDATER_ADDRESS true \
  --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY
```

## Verification & Testing

### Contract Verification
```bash
# Verify contracts on Etherscan
forge verify-contract $HOOK_ADDRESS src/EigenLVR_V2.sol:EigenLVR_V2 \
  --chain-id 1 \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,address,address,address,uint256)" $AVS_DIRECTORY $PRICE_ORACLE $CROSS_CHAIN_MONITOR $PRIVATE_AUCTION_MANAGER 50)
```

### Integration Testing
```bash
# Run integration tests
forge test --match-path "test/unit/EigenLVR_V2_IntegrationTests.t.sol" \
  --fork-url $RPC_URL

# Run full test suite
forge test --fork-url $RPC_URL
```

### Load Testing
```bash
# Run performance tests
forge test --match-path "test/unit/EigenLVR_V2_*Tests.t.sol" \
  --gas-report \
  --fork-url $RPC_URL
```

## Monitoring & Maintenance

### Health Checks
```bash
# Check contract status
cast call $HOOK_ADDRESS "paused()" --rpc-url $RPC_URL
cast call $HOOK_ADDRESS "lvrThreshold()" --rpc-url $RPC_URL
```

### Event Monitoring
```bash
# Monitor key events
cast logs --from-block latest --to-block latest \
  --address $HOOK_ADDRESS \
  --rpc-url $RPC_URL
```

### Emergency Procedures

#### Pause Contract
```bash
# Emergency pause
cast send $HOOK_ADDRESS "pause()" \
  --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY
```

#### Unpause Contract
```bash
# Resume operations
cast send $HOOK_ADDRESS "unpause()" \
  --rpc-url $RPC_URL \
  --private-key $OWNER_PRIVATE_KEY
```

## Security Considerations

### Access Control
- Use multi-sig wallets for ownership
- Implement role-based access control
- Regular key rotation procedures
- Emergency pause capabilities

### Monitoring
- Real-time event monitoring
- Gas usage tracking
- Anomaly detection
- Automated alerting

### Backup & Recovery
- Regular state snapshots
- Emergency recovery procedures
- Disaster recovery planning
- Incident response protocols

## Troubleshooting

### Common Issues

#### Deployment Failures
- Check gas limits and prices
- Verify environment variables
- Ensure sufficient ETH balance
- Check network connectivity

#### Verification Failures
- Verify constructor arguments
- Check contract source code
- Ensure proper compiler settings
- Verify bytecode matches

#### Integration Issues
- Check external contract addresses
- Verify interface implementations
- Ensure proper authorization
- Check network compatibility

### Support Resources
- [Documentation](docs/)
- [GitHub Issues](https://github.com/your-org/EigenLVR_v2/issues)
- [Discord Community](https://discord.gg/your-discord)
- [Telegram Support](https://t.me/your-telegram)
