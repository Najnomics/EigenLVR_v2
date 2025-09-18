# EigenLVR v2 Deployment Guide

## Overview

This guide covers the complete deployment process for EigenLVR v2 across different environments and networks. The deployment includes smart contracts, EigenLayer AVS components, and Fhenix FHE integration.

## Prerequisites

### Required Software
- **Foundry**: Latest version with via-IR support
- **Node.js**: v18+ with pnpm package manager
- **Go**: v1.21+ for AVS components
- **Docker**: For containerized deployments

### Required Accounts
- **Ethereum Account**: With sufficient ETH for gas fees
- **EigenLayer Account**: For AVS registration and operator management
- **Fhenix Account**: For FHE network access
- **API Keys**: Infura, Alchemy, or other RPC providers

## Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/Najnomics/EigenLVR_v2.git
cd EigenLVR_v2
```

### 2. Install Dependencies
```bash
# Install Node.js dependencies
pnpm install

# Install Foundry dependencies
forge install --no-commit

# Install Go dependencies (for AVS)
cd avs
go mod tidy
cd ..
```

### 3. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

## Smart Contract Deployment

### 1. Local Development (Anvil)

#### Start Local Blockchain
```bash
# Start Anvil
make start-anvil

# Or manually
anvil --host 0.0.0.0 --port 8545 --chain-id 31337
```

#### Deploy Contracts
```bash
# Deploy using Makefile
make deploy-anvil

# Or manually
forge script script/DeployEnhanced.s.sol \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast \
  --via-ir
```

#### Verify Deployment
```bash
# Check deployment status
make status

# Run tests against deployed contracts
forge test --via-ir --fork-url http://localhost:8545
```

### 2. Testnet Deployment

#### Sepolia Testnet
```bash
# Deploy to Sepolia
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ETHEREUM_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --via-ir
```

#### Arbitrum Sepolia
```bash
# Deploy to Arbitrum Sepolia
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ARBITRUM_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --via-ir
```

#### Optimism Sepolia
```bash
# Deploy to Optimism Sepolia
forge script script/DeployEnhanced.s.sol \
  --rpc-url $OPTIMISM_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --via-ir
```

### 3. Mainnet Deployment

#### Ethereum Mainnet
```bash
# Deploy to Ethereum Mainnet
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --slow \
  --via-ir
```

#### Arbitrum One
```bash
# Deploy to Arbitrum One
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ARBITRUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --slow \
  --via-ir
```

#### Optimism
```bash
# Deploy to Optimism
forge script script/DeployEnhanced.s.sol \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --slow \
  --via-ir
```

## EigenLayer AVS Deployment

### 1. AVS Registration

#### Register with EigenLayer
```bash
# Navigate to AVS directory
cd avs

# Build AVS contracts
forge build --via-ir

# Deploy AVS contracts
forge script script/DeployAVS.s.sol \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --via-ir
```

#### Configure AVS Parameters
```bash
# Set AVS parameters
cast send $AVS_ADDRESS "setParameters(uint256,uint256,uint256)" \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  86400 1000000000000000000 10000000000000000000
```

### 2. Operator Setup

#### Deploy Operator
```bash
# Build operator binary
cd avs
go build -o bin/operator cmd/main.go

# Run operator
./bin/operator \
  --config config/operator.yaml \
  --private-key $OPERATOR_PRIVATE_KEY \
  --rpc-url $ETHEREUM_RPC_URL
```

#### Register Operator
```bash
# Register operator with AVS
cast send $AVS_ADDRESS "registerOperator(address)" \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $OPERATOR_PRIVATE_KEY \
  $OPERATOR_ADDRESS
```

### 3. AVS Configuration

#### Operator Configuration
```yaml
# config/operator.yaml
operator:
  address: "0x..."
  private_key: "0x..."
  stake_amount: "1000000000000000000000"
  
eigenlayer:
  avs_address: "0x..."
  service_manager: "0x..."
  
rpc:
  ethereum: "https://mainnet.infura.io/v3/..."
  arbitrum: "https://arbitrum-mainnet.infura.io/v3/..."
  optimism: "https://optimism-mainnet.infura.io/v3/..."
  
monitoring:
  price_feeds:
    - chain_id: 1
      oracle: "0x..."
    - chain_id: 42161
      oracle: "0x..."
    - chain_id: 10
      oracle: "0x..."
```

## Fhenix FHE Integration

### 1. Fhenix Network Setup

#### Connect to Fhenix
```bash
# Set Fhenix RPC URL
export FHENIX_RPC_URL="https://api.fhenix.zone"

# Set Fhenix private key
export FHENIX_PRIVATE_KEY="0x..."
```

#### Deploy FHE Contracts
```bash
# Deploy PrivateAuctionManager
forge script script/DeployFHE.s.sol \
  --rpc-url $FHENIX_RPC_URL \
  --private-key $FHENIX_PRIVATE_KEY \
  --broadcast \
  --via-ir
```

### 2. FHE Configuration

#### Initialize FHE Permissions
```bash
# Initialize FHE permissions
cast send $PRIVATE_AUCTION_MANAGER_ADDRESS "initializeFHE()" \
  --rpc-url $FHENIX_RPC_URL \
  --private-key $FHENIX_PRIVATE_KEY
```

#### Configure FHE Parameters
```bash
# Set FHE parameters
cast send $PRIVATE_AUCTION_MANAGER_ADDRESS "setFHEParameters(uint256,uint256)" \
  --rpc-url $FHENIX_RPC_URL \
  --private-key $FHENIX_PRIVATE_KEY \
  1000000000000000000 86400
```

## Cross-Chain Configuration

### 1. Chain Registry Setup

#### Register Supported Chains
```bash
# Register Ethereum
cast send $CHAIN_REGISTRY_ADDRESS "registerChain(uint256,address,address)" \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  1 $ORACLE_ADDRESS $BRIDGE_ADDRESS

# Register Arbitrum
cast send $CHAIN_REGISTRY_ADDRESS "registerChain(uint256,address,address)" \
  --rpc-url $ARBITRUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  42161 $ORACLE_ADDRESS $BRIDGE_ADDRESS

# Register Optimism
cast send $CHAIN_REGISTRY_ADDRESS "registerChain(uint256,address,address)" \
  --rpc-url $OPTIMISM_RPC_URL \
  --private-key $PRIVATE_KEY \
  10 $ORACLE_ADDRESS $BRIDGE_ADDRESS
```

### 2. Price Oracle Configuration

#### Set Oracle Addresses
```bash
# Set Chainlink oracles
cast send $CROSS_CHAIN_MONITOR_ADDRESS "setOracle(uint256,address)" \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  1 $CHAINLINK_ORACLE_ADDRESS

# Set Pyth oracles
cast send $CROSS_CHAIN_MONITOR_ADDRESS "setOracle(uint256,address)" \
  --rpc-url $ARBITRUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  42161 $PYTH_ORACLE_ADDRESS
```

## Verification and Testing

### 1. Contract Verification

#### Verify on Etherscan
```bash
# Verify main contract
forge verify-contract $EIGENLVR_V2_ADDRESS \
  --chain-id 1 \
  --etherscan-api-key $ETHERSCAN_API_KEY

# Verify cross-chain components
forge verify-contract $CROSS_CHAIN_MONITOR_ADDRESS \
  --chain-id 1 \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### 2. Integration Testing

#### Run Integration Tests
```bash
# Run all tests
make test

# Run specific test suites
forge test --via-ir --match-contract EigenLVR_V2Test
forge test --via-ir --match-contract CrossChainTests
forge test --via-ir --match-contract PrivateAuctionTests
```

#### Test Cross-Chain Functionality
```bash
# Test cross-chain price monitoring
forge test --via-ir --match-test testCrossChainPriceMonitoring

# Test cross-chain arbitrage
forge test --via-ir --match-test testCrossChainArbitrage
```

### 3. Performance Testing

#### Gas Optimization
```bash
# Generate gas report
make test-gas

# Create gas snapshot
make gas-snapshot
```

#### Load Testing
```bash
# Run load tests
forge test --via-ir --match-test testLoad --fuzz-runs 10000
```

## Monitoring and Maintenance

### 1. Health Checks

#### Contract Health
```bash
# Check contract status
cast call $EIGENLVR_V2_ADDRESS "isPaused()" --rpc-url $ETHEREUM_RPC_URL

# Check AVS status
cast call $AVS_ADDRESS "isActive()" --rpc-url $ETHEREUM_RPC_URL
```

#### Operator Health
```bash
# Check operator status
curl -X GET "http://localhost:8080/health"

# Check operator metrics
curl -X GET "http://localhost:8080/metrics"
```

### 2. Logging and Monitoring

#### Event Monitoring
```bash
# Monitor auction events
cast logs --from-block latest --address $EIGENLVR_V2_ADDRESS \
  --topic "AuctionStarted(bytes32,bytes32,uint256,uint256,bool)" \
  --rpc-url $ETHEREUM_RPC_URL
```

#### Performance Metrics
```bash
# Monitor gas usage
cast call $EIGENLVR_V2_ADDRESS "getGasUsage()" --rpc-url $ETHEREUM_RPC_URL

# Monitor MEV distribution
cast call $EIGENLVR_V2_ADDRESS "getTotalMEVDistributed()" --rpc-url $ETHEREUM_RPC_URL
```

## Troubleshooting

### Common Issues

#### Deployment Failures
```bash
# Check gas limits
forge script script/DeployEnhanced.s.sol --dry-run

# Check contract size
forge build --via-ir --sizes
```

#### AVS Registration Issues
```bash
# Check operator stake
cast call $AVS_ADDRESS "getOperatorStake(address)" $OPERATOR_ADDRESS --rpc-url $ETHEREUM_RPC_URL

# Check AVS parameters
cast call $AVS_ADDRESS "getParameters()" --rpc-url $ETHEREUM_RPC_URL
```

#### FHE Integration Issues
```bash
# Check FHE permissions
cast call $PRIVATE_AUCTION_MANAGER_ADDRESS "hasPermission(address)" $OPERATOR_ADDRESS --rpc-url $FHENIX_RPC_URL

# Check FHE status
cast call $PRIVATE_AUCTION_MANAGER_ADDRESS "isInitialized()" --rpc-url $FHENIX_RPC_URL
```

### Support

For additional support:
- **Discord**: [EigenLVR Community](https://discord.gg/eigenlvr)
- **GitHub Issues**: [Report Issues](https://github.com/Najnomics/EigenLVR_v2/issues)
- **Documentation**: [Full Docs](https://docs.eigenlvr.com)
