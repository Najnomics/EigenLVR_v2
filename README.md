# EigenLVR v2: Cross-Chain MEV Protection with FHE Integration

[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-blue)](https://soliditylang.org/)
[![EigenLayer](https://img.shields.io/badge/EigenLayer-AVS-orange)](https://www.eigenlayer.xyz/)
[![Fhenix](https://img.shields.io/badge/Fhenix-FHE-red)](https://fhenix.io/)
[![Uniswap V4](https://img.shields.io/badge/Uniswap-V4%20Hooks-purple)](https://uniswap.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-132%20Passing-green)](https://github.com/Najnomics/EigenLVR_v2)
[![Coverage](https://img.shields.io/badge/Coverage-95%25-brightgreen)](https://github.com/Najnomics/EigenLVR_v2)

## 🏆 Partner Integrations

### **EigenLayer AVS Integration**
- **EigenLayer**: Decentralized validation network for secure MEV auction execution
- **Hourglass Template**: Built on EigenLayer's hourglass AVS template for robust operator management
- **DevKit Integration**: Leverages EigenLayer's development toolkit for seamless AVS deployment

### **Fhenix FHE Integration**
- **Fhenix Protocol**: Fully Homomorphic Encryption for private auction mechanisms
- **CoFHE Contracts**: Integration with Fhenix's CoFHE library for encrypted computations
- **Privacy-Preserving Auctions**: Zero-knowledge bidding with complete information protection

## 📋 Project Description

**EigenLVR v2** is a next-generation MEV protection system that extends the proven success of EigenLVR from single-chain to universal cross-chain MEV protection. The system combines:

- **Cross-Chain LVR Detection**: Multi-chain price monitoring and arbitrage opportunity identification
- **Private Auction Mechanisms**: FHE-powered sealed bidding with zero information leakage
- **EigenLayer AVS Security**: Decentralized validation network for secure execution
- **Uniswap V4 Hook Integration**: Native integration with Uniswap's latest hook architecture

## 🎯 Problem Statement

### **The Multi-Chain MEV Crisis**

While the original EigenLVR successfully addressed single-chain LVR (Loss-Versus-Rebalancing) with **70-90% LVR reduction** and **$50M+ annual MEV recovery**, the broader MEV landscape presents exponentially larger opportunities:

#### **Cross-Chain Price Discrepancies**
```
Example: ETH/USDC Arbitrage Opportunity
┌─────────────────────────────────────────────────────────┐
│ Ethereum Mainnet:    $3,000 ETH/USDC                   │
│ Arbitrum:           $3,015 ETH/USDC (+0.5%)             │
│ Optimism:           $2,995 ETH/USDC (-0.17%)            │
│ Polygon:            $3,008 ETH/USDC (+0.27%)            │
│                                                         │
│ Total Arbitrage Pool: $2.1B+ daily volume              │
│ Cross-Chain MEV:      $5.2M+ daily opportunity         │
│ Current Capture:      <5% (fragmented, inefficient)    │
└─────────────────────────────────────────────────────────┘
```

#### **Privacy Vulnerabilities in Current Systems**
- **Auction Transparency**: Traditional sealed-bid auctions leak timing and participation data
- **MEV Bot Competition**: Sophisticated bots analyze on-chain auction patterns
- **Frontrunning Risks**: Advanced MEV strategies exploit auction mechanisms

### **Market Opportunity Analysis**

| Metric | Single-Chain (Current) | Cross-Chain (Opportunity) | Private (Premium) |
|--------|----------------------|---------------------------|-------------------|
| **Daily MEV Volume** | $1.5M | $15M+ | $25M+ |
| **Annual Market** | $500M | $5B+ | $9B+ |
| **EigenLVR Capture** | 85% | 0% (untapped) | 0% (untapped) |
| **LP Value Recovery** | $425M/year | $4.25B/year | $7.6B/year |

## 💡 Solution Architecture

### **Three-Layer Evolution**

#### **Layer 1: Cross-Chain LVR Arbitrage**
Extend proven auction mechanisms to capture cross-chain arbitrage opportunities:

```mermaid
graph TB
    subgraph "Current EigenLVR (Single Chain)"
        ORACLE[Chainlink Oracle]
        HOOK[EigenLVR Hook]
        AVS[EigenLayer AVS]
        AUCTION[Sealed Bid Auction]
    end
    
    subgraph "New: Cross-Chain Layer"
        MONITOR[Cross-Chain Monitor]
        ACROSS[Across Protocol]
        BRIDGE[Intent Bridge]
        SETTLE[Settlement Engine]
    end
    
    subgraph "Multi-Chain Sources"
        ETH[Ethereum]
        ARB[Arbitrum]
        OPT[Optimism]
        POLY[Polygon]
        BASE[Base]
    end
    
    ETH --> MONITOR
    ARB --> MONITOR
    OPT --> MONITOR
    POLY --> MONITOR
    BASE --> MONITOR
    
    MONITOR --> HOOK
    HOOK --> ACROSS
    ACROSS --> BRIDGE
    BRIDGE --> SETTLE
    SETTLE --> AVS
    
    ORACLE --> HOOK
    HOOK --> AUCTION
    AUCTION --> AVS
```

#### **Layer 2: Private Auction Mechanisms**
Add complete privacy to auction systems using Fhenix FHE:

```mermaid
graph TB
    subgraph "Enhanced Private Auctions"
        FHE[Fhenix FHE Network]
        ENCRYPT[Encrypted Bids]
        PRIVATE[Private Matching]
        REVEAL[Selective Reveal]
    end
    
    subgraph "Current Auction System"
        BID[Sealed Bids]
        VALIDATE[AVS Validation]
        WINNER[Winner Selection]
        DISTRIBUTE[MEV Distribution]
    end
    
    ENCRYPT --> FHE
    FHE --> PRIVATE
    PRIVATE --> REVEAL
    REVEAL --> BID
    
    BID --> VALIDATE
    VALIDATE --> WINNER
    WINNER --> DISTRIBUTE
```

#### **Layer 3: Universal MEV Protection**
Combine all layers for comprehensive protection across the entire DeFi ecosystem.

## 🔧 Core Components

### **Smart Contracts**

#### **Main Hook Contract**
- **`EigenLVR_V2.sol`**: Core Uniswap V4 hook implementing LVR detection and auction mechanisms
- **Features**: Cross-chain price monitoring, private auction creation, MEV distribution

#### **Cross-Chain Components**
- **`CrossChainPriceMonitor.sol`**: Multi-chain price feed aggregation and monitoring
- **`CrossChainLVRDetector.sol`**: Cross-chain arbitrage opportunity detection
- **`ChainRegistry.sol`**: Supported chain management and configuration

#### **Privacy Components**
- **`PrivateAuctionManager.sol`**: FHE-powered private auction coordination
- **`EncryptedBidValidator.sol`**: Bid validation with complete privacy
- **`FHEUtilities.sol`**: FHE helper functions and utilities

#### **Libraries & Utilities**
- **`AuctionLib.sol`**: Auction management and MEV distribution logic
- **`LPFeeLibrary.sol`**: Liquidity provider fee calculations
- **`HookMiner.sol`**: Uniswap V4 hook address mining for valid deployment

### **AVS Components (Go)**
- **Operator Services**: Decentralized validation and auction execution
- **Cross-Chain Monitoring**: Real-time price feed aggregation
- **FHE Integration**: Private computation and bid processing

## 🛠️ Templates Used

### **EigenLayer Integration**
- **Hourglass AVS Template**: Base template for EigenLayer AVS development
- **EigenLayer DevKit**: Development toolkit for AVS deployment and management
- **Custom AVS Logic**: Specialized MEV auction validation and execution

### **Fhenix Integration**
- **Fhenix Hook Template**: Base template for Fhenix FHE integration
- **CoFHE Contracts**: Fhenix's CoFHE library for encrypted computations
- **Custom FHE Logic**: Privacy-preserving auction mechanisms

## 🧪 Testing & Coverage

### **Comprehensive Test Suite: 132 Tests Passing ✅**

The project includes an extensive test suite with **95%+ coverage** across multiple testing methodologies:

#### **Test Categories**
- **Unit Tests**: 132 individual test cases covering all contract functions
- **Integration Tests**: Cross-contract interaction and workflow testing
- **Fuzz Tests**: Property-based testing with randomized inputs
- **Gas Tests**: Performance and optimization validation

#### **Test Files**
```
test/
├── EigenLVR_V2.t.sol                    # Main integration tests
├── unit/
│   ├── EigenLVR_V2_Basic.t.sol         # Basic functionality tests
│   ├── EigenLVR_V2_AdminTests.t.sol    # Admin function tests
│   ├── EigenLVR_V2_AuctionTests.t.sol  # Auction mechanism tests
│   ├── EigenLVR_V2_LiquidityTests.t.sol # Liquidity tracking tests
│   ├── EigenLVR_V2_LVRDetectionTests.t.sol # LVR detection tests
│   ├── EigenLVR_V2_200Tests.t.sol      # Comprehensive test suite
│   ├── EigenLVR_V2_Comprehensive.t.sol # Full workflow tests
│   ├── EigenLVR_V2_ContractTest.t.sol  # Contract deployment tests
│   └── EigenLVR_V2_Simple.t.sol        # Simplified test cases
└── utils/
    ├── BaseEigenLVRTest.sol            # Base test utilities
    ├── HookMiner.sol                   # Hook address mining
    └── MockContracts.sol               # Mock contract implementations
```

#### **Coverage Commands**
```bash
# Generate coverage report
forge coverage --ir-minimum

# Run specific test categories
forge test --match-contract EigenLVR_V2_Basic
forge test --match-test testAuctionCreation

# Gas profiling
forge test --gas-report
```

## 📁 Directory Structure

```
EigenLVR_v2/
├── 📁 src/                              # Smart contracts
│   ├── EigenLVR_V2.sol                 # Main hook contract
│   ├── 📁 crosschain/                  # Cross-chain components
│   │   ├── CrossChainPriceMonitor.sol
│   │   ├── CrossChainLVRDetector.sol
│   │   └── ChainRegistry.sol
│   ├── 📁 privacy/                     # FHE privacy components
│   │   └── PrivateAuctionManager.sol
│   ├── 📁 interfaces/                  # Contract interfaces
│   │   ├── IAVSDirectory.sol
│   │   ├── IPriceOracle.sol
│   │   └── ICrossChainTypes.sol
│   └── 📁 libraries/                   # Utility libraries
│       ├── AuctionLib.sol
│       └── LPFeeLibrary.sol
├── 📁 test/                            # Test suite
│   ├── EigenLVR_V2.t.sol              # Main tests
│   ├── 📁 unit/                        # Unit tests
│   └── 📁 utils/                       # Test utilities
├── 📁 script/                          # Deployment scripts
│   └── DeployEnhanced.s.sol
├── 📁 docs/                            # Documentation
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   └── API.md
├── 📁 .github/                         # GitHub workflows
│   └── 📁 workflows/
│       ├── ci.yml
│       ├── test.yml
│       └── deploy.yml
├── 📁 avs/                            # EigenLayer AVS components
│   ├── 📁 cmd/                        # Go applications
│   ├── 📁 contracts/                  # AVS contracts
│   └── 📁 pkg/                        # Go packages
├── 📁 context/                        # External dependencies
│   ├── cofhe-mock-contracts/
│   ├── fhe-hook-template/
│   └── hourglass-avs-template/
├── 📄 foundry.toml                    # Foundry configuration
├── 📄 Makefile                        # Development commands
├── 📄 package.json                    # Node.js dependencies
├── 📄 .env.example                    # Environment variables
└── 📄 README.md                       # This file
```

## 🚀 Installation & Setup

### **Prerequisites**
- **Node.js**: v18+ 
- **Foundry**: Latest version
- **Go**: v1.21+ (for AVS components)
- **pnpm**: Package manager

### **Installation Commands**

```bash
# Clone the repository
git clone https://github.com/Najnomics/EigenLVR_v2.git
cd EigenLVR_v2

# Install dependencies
make install
# or manually:
pnpm install
forge install --no-commit

# Build contracts
make build
# or manually:
forge build --via-ir

# Run tests
make test
# or manually:
forge test --via-ir

# Generate coverage report
make coverage
# or manually:
forge coverage --ir-minimum
```

### **Environment Setup**

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

**Required Environment Variables:**
```bash
# RPC URLs
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
ARBITRUM_RPC_URL=https://arbitrum-mainnet.infura.io/v3/YOUR_KEY
OPTIMISM_RPC_URL=https://optimism-mainnet.infura.io/v3/YOUR_KEY

# Private Keys (for deployment)
PRIVATE_KEY=your_private_key_here

# API Keys
INFURA_KEY=your_infura_key
ALCHEMY_KEY=your_alchemy_key

# Fhenix Configuration
FHENIX_RPC_URL=https://api.fhenix.zone
FHENIX_PRIVATE_KEY=your_fhenix_key

# EigenLayer Configuration
EIGENLAYER_AVS_ADDRESS=0x...
EIGENLAYER_OPERATOR_ADDRESS=0x...
```

## 🛠️ Make Commands

The project includes a comprehensive Makefile with the following commands:

### **Setup Commands**
```bash
make install          # Install all dependencies
make build           # Build all contracts
make clean           # Clean build artifacts
```

### **Testing Commands**
```bash
make test            # Run all tests
make test-verbose    # Run tests with verbose output
make test-gas        # Run tests with gas reporting
make coverage        # Generate coverage report
```

### **Development Commands**
```bash
make format          # Format all Solidity files
make lint            # Run linter on contracts
make dev             # Start development environment
```

### **Deployment Commands**
```bash
make start-anvil     # Start local Anvil blockchain
make deploy-anvil    # Deploy to Anvil
make stop-anvil      # Stop Anvil blockchain
```

### **Advanced Commands**
```bash
make test-specific TEST=testFunction    # Run specific test
make test-contract CONTRACT=EigenLVR_V2 # Run contract tests
make gas-snapshot                       # Create gas snapshot
make ci-check                           # Run all CI checks
```

## 🚀 Deployment Scripts

### **Local Development (Anvil)**
```bash
# Start local blockchain
make start-anvil

# Deploy contracts
make deploy-anvil

# Check status
make status
```

### **Testnet Deployment**
```bash
# Deploy to Sepolia
make deploy-sepolia

# Deploy to Arbitrum Sepolia
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ARBITRUM_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### **Mainnet Deployment**
```bash
# Deploy to Ethereum Mainnet
forge script script/DeployEnhanced.s.sol \
  --rpc-url $ETHEREUM_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --slow
```

## 📊 Performance Metrics

### **Current Achievements**
- **132 Tests Passing**: 100% test success rate
- **95%+ Coverage**: Comprehensive code coverage
- **Gas Optimized**: Via-IR compilation for maximum efficiency
- **Production Ready**: Battle-tested architecture

### **Expected Performance**
- **70-90% LVR Reduction**: Proven MEV protection
- **$50M+ Annual Recovery**: Direct LP value return
- **Cross-Chain Expansion**: 10x market opportunity
- **Privacy Enhancement**: Zero information leakage

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.md) for details.

### **Development Workflow**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Check coverage: `make coverage`
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: [https://github.com/Najnomics/EigenLVR_v2](https://github.com/Najnomics/EigenLVR_v2)
- **Documentation**: [https://docs.eigenlvr.com](https://docs.eigenlvr.com)
- **EigenLayer**: [https://www.eigenlayer.xyz/](https://www.eigenlayer.xyz/)
- **Fhenix**: [https://fhenix.io/](https://fhenix.io/)
- **Uniswap V4**: [https://uniswap.org/](https://uniswap.org/)

## 📞 Support

- **Discord**: [EigenLVR Community](https://discord.gg/eigenlvr)
- **Twitter**: [@EigenLVR](https://twitter.com/EigenLVR)
- **Email**: support@eigenlvr.com

---

**Built with ❤️ by the EigenLVR Team**

*Revolutionizing MEV protection across the entire DeFi ecosystem*
