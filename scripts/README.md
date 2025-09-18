# EigenLVR v2 Deployment Scripts

This directory contains deployment scripts for EigenLVR v2 across different environments and networks.

## Scripts Overview

### 1. `deploy-anvil.sh` - Local Development
Deploys contracts to local Anvil blockchain for development and testing.

**Usage:**
```bash
./scripts/deploy-anvil.sh
```

**Prerequisites:**
- Anvil running on localhost:8545
- Contracts built (`forge build`)

**Features:**
- Automatic Anvil connection check
- Contract building if needed
- Basic test execution
- Deployment address extraction
- JSON output with contract addresses

### 2. `deploy-testnet.sh` - Testnet Deployment
Deploys contracts to testnet networks for testing and validation.

**Usage:**
```bash
# Deploy to Sepolia
./scripts/deploy-testnet.sh sepolia

# Deploy to Arbitrum Sepolia
./scripts/deploy-testnet.sh arbitrum-sepolia

# Deploy to Optimism Sepolia
./scripts/deploy-testnet.sh optimism-sepolia

# Deploy without verification
./scripts/deploy-testnet.sh sepolia false
```

**Supported Networks:**
- `sepolia` - Ethereum Sepolia testnet
- `arbitrum-sepolia` - Arbitrum Sepolia testnet
- `optimism-sepolia` - Optimism Sepolia testnet

**Prerequisites:**
- Environment variables set (see `.env.example`)
- Sufficient testnet ETH for gas fees
- API keys for contract verification

**Features:**
- Network-specific configuration
- Optional contract verification
- Pre and post-deployment testing
- Explorer link generation
- JSON output with contract addresses

### 3. `deploy-mainnet.sh` - Mainnet Deployment
Deploys contracts to mainnet networks for production use.

**Usage:**
```bash
# Deploy to Ethereum mainnet
./scripts/deploy-mainnet.sh ethereum

# Deploy to Arbitrum
./scripts/deploy-mainnet.sh arbitrum

# Deploy to Optimism
./scripts/deploy-mainnet.sh optimism

# Deploy to Polygon
./scripts/deploy-mainnet.sh polygon

# Deploy to Base
./scripts/deploy-mainnet.sh base

# Deploy without verification
./scripts/deploy-mainnet.sh ethereum false

# Deploy with fast mode (no --slow flag)
./scripts/deploy-mainnet.sh ethereum true false
```

**Supported Networks:**
- `ethereum` - Ethereum mainnet
- `arbitrum` - Arbitrum One
- `optimism` - Optimism
- `polygon` - Polygon
- `base` - Base

**Prerequisites:**
- Environment variables set (see `.env.example`)
- Sufficient mainnet ETH for gas fees
- API keys for contract verification
- Security audit completed
- Comprehensive testing completed

**Features:**
- Safety checks and confirmations
- Comprehensive pre-deployment testing
- Security audit integration
- Network-specific configuration
- Contract verification
- Discord notification support
- Explorer link generation
- JSON output with contract addresses

## Environment Setup

### 1. Copy Environment Template
```bash
cp .env.example .env
```

### 2. Configure Environment Variables
Edit `.env` file with your values:

**Required Variables:**
```bash
# RPC URLs
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
ARBITRUM_RPC_URL=https://arbitrum-mainnet.infura.io/v3/YOUR_KEY
OPTIMISM_RPC_URL=https://optimism-mainnet.infura.io/v3/YOUR_KEY

# Private Keys
PRIVATE_KEY=0x...
OPERATOR_PRIVATE_KEY=0x...
FHENIX_PRIVATE_KEY=0x...

# API Keys
INFURA_KEY=your_infura_key
ALCHEMY_KEY=your_alchemy_key
ETHERSCAN_API_KEY=your_etherscan_key
ARBISCAN_API_KEY=your_arbiscan_key
```

### 3. Install Dependencies
```bash
# Install Node.js dependencies
pnpm install

# Install Foundry dependencies
forge install --no-commit
```

## Deployment Workflow

### 1. Local Development
```bash
# Start Anvil
anvil --host 0.0.0.0 --port 8545 --chain-id 31337

# Deploy to Anvil
./scripts/deploy-anvil.sh

# Test contracts
forge test --fork-url http://localhost:8545
```

### 2. Testnet Deployment
```bash
# Deploy to Sepolia
./scripts/deploy-testnet.sh sepolia

# Test deployment
forge test --fork-url $ETHEREUM_SEPOLIA_RPC_URL

# Verify contracts on Etherscan
```

### 3. Mainnet Deployment
```bash
# Final testing
forge test --fork-url $ETHEREUM_RPC_URL

# Security audit
slither .

# Deploy to mainnet
./scripts/deploy-mainnet.sh ethereum

# Verify contracts
# Set up monitoring
# Announce deployment
```

## Output Files

Each deployment script generates a JSON file with contract addresses:

### `deployed-contracts-anvil.json`
```json
{
  "network": "anvil",
  "chainId": 31337,
  "rpcUrl": "http://localhost:8545",
  "deployer": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "contracts": {
    "EigenLVR_V2": "0x...",
    "CrossChainPriceMonitor": "0x...",
    "PrivateAuctionManager": "0x...",
    "ChainRegistry": "0x..."
  },
  "deployedAt": "2024-01-01T00:00:00Z"
}
```

### `deployed-contracts-{network}.json`
```json
{
  "network": "ethereum",
  "chainId": 1,
  "rpcUrl": "https://mainnet.infura.io/v3/...",
  "explorerUrl": "https://etherscan.io",
  "contracts": {
    "EigenLVR_V2": "0x...",
    "CrossChainPriceMonitor": "0x...",
    "PrivateAuctionManager": "0x...",
    "ChainRegistry": "0x..."
  },
  "deployedAt": "2024-01-01T00:00:00Z"
}
```

## Troubleshooting

### Common Issues

#### 1. Network Connection Failed
```bash
# Check RPC URL
curl -s $RPC_URL

# Verify environment variables
echo $ETHEREUM_RPC_URL
```

#### 2. Insufficient Gas
```bash
# Check account balance
cast balance $ACCOUNT --rpc-url $RPC_URL

# Increase gas price
export GAS_PRICE_MULTIPLIER=1.2
```

#### 3. Contract Verification Failed
```bash
# Check API key
echo $ETHERSCAN_API_KEY

# Verify manually
forge verify-contract $CONTRACT_ADDRESS --chain-id 1 --etherscan-api-key $ETHERSCAN_API_KEY
```

#### 4. Tests Failing
```bash
# Run tests with verbose output
forge test --fork-url $RPC_URL -vvv

# Run specific test
forge test --fork-url $RPC_URL --match-test testSpecific
```

### Debug Mode

Enable debug mode for detailed output:
```bash
# Set debug environment variable
export DEBUG=true

# Run deployment script
./scripts/deploy-testnet.sh sepolia
```

## Security Considerations

### 1. Private Key Security
- Never commit private keys to version control
- Use environment variables or secure key management
- Consider using hardware wallets for mainnet deployments

### 2. Pre-deployment Checks
- Run comprehensive tests
- Perform security audits
- Review contract code
- Verify environment variables

### 3. Post-deployment Verification
- Verify contracts on explorer
- Test all functions
- Set up monitoring
- Configure alerting

## Monitoring and Alerting

### 1. Discord Notifications
Set `DISCORD_WEBHOOK_URL` in your environment to receive deployment notifications.

### 2. Contract Monitoring
- Monitor contract events
- Track gas usage
- Monitor MEV distribution
- Alert on anomalies

### 3. Health Checks
```bash
# Check contract status
cast call $EIGENLVR_V2_ADDRESS "isPaused()" --rpc-url $RPC_URL

# Check AVS status
cast call $AVS_ADDRESS "isActive()" --rpc-url $RPC_URL
```

## Support

For deployment support:
- **Discord**: [EigenLVR Community](https://discord.gg/eigenlvr)
- **GitHub Issues**: [Report Issues](https://github.com/Najnomics/EigenLVR_v2/issues)
- **Documentation**: [Full Docs](https://docs.eigenlvr.com)
