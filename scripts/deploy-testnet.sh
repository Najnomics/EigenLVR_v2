#!/bin/bash

# EigenLVR v2 - Testnet Deployment Script
# Deploys contracts to testnet networks (Sepolia, Arbitrum Sepolia, Optimism Sepolia)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK=${1:-"sepolia"}
VERIFY=${2:-"true"}

# Network configurations
case $NETWORK in
    "sepolia")
        RPC_URL=$ETHEREUM_SEPOLIA_RPC_URL
        CHAIN_ID=11155111
        EXPLORER_API_KEY=$ETHERSCAN_API_KEY
        EXPLORER_URL="https://sepolia.etherscan.io"
        ;;
    "arbitrum-sepolia")
        RPC_URL=$ARBITRUM_SEPOLIA_RPC_URL
        CHAIN_ID=421614
        EXPLORER_API_KEY=$ARBISCAN_API_KEY
        EXPLORER_URL="https://sepolia.arbiscan.io"
        ;;
    "optimism-sepolia")
        RPC_URL=$OPTIMISM_SEPOLIA_RPC_URL
        CHAIN_ID=11155420
        EXPLORER_API_KEY=$OPTIMISM_ETHERSCAN_API_KEY
        EXPLORER_URL="https://sepolia-optimism.etherscan.io"
        ;;
    *)
        echo -e "${RED}❌ Unsupported network: $NETWORK${NC}"
        echo "Supported networks: sepolia, arbitrum-sepolia, optimism-sepolia"
        exit 1
        ;;
esac

echo -e "${BLUE}🚀 EigenLVR v2 - Testnet Deployment${NC}"
echo "====================================="
echo -e "${YELLOW}Network: $NETWORK${NC}"
echo -e "${YELLOW}Chain ID: $CHAIN_ID${NC}"
echo -e "${YELLOW}Verify: $VERIFY${NC}"

# Check environment variables
echo -e "${YELLOW}Checking environment variables...${NC}"
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}❌ PRIVATE_KEY environment variable is not set${NC}"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo -e "${RED}❌ ${NETWORK^^}_RPC_URL environment variable is not set${NC}"
    exit 1
fi

if [ "$VERIFY" = "true" ] && [ -z "$EXPLORER_API_KEY" ]; then
    echo -e "${RED}❌ ${NETWORK^^}_API_KEY environment variable is not set for verification${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Environment variables are set${NC}"

# Check if Anvil is running
echo -e "${YELLOW}Checking network connection...${NC}"
if ! curl -s $RPC_URL > /dev/null; then
    echo -e "${RED}❌ Cannot connect to $NETWORK RPC URL${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Network connection successful${NC}"

# Check if contracts are built
echo -e "${YELLOW}Checking if contracts are built...${NC}"
if [ ! -d "out" ]; then
    echo -e "${YELLOW}Building contracts...${NC}"
    forge build --via-ir
fi
echo -e "${GREEN}✅ Contracts are built${NC}"

# Run tests before deployment
echo -e "${YELLOW}Running tests before deployment...${NC}"
forge test --via-ir --fork-url $RPC_URL
echo -e "${GREEN}✅ Tests passed${NC}"

# Deploy contracts
echo -e "${YELLOW}Deploying contracts to $NETWORK...${NC}"

if [ "$VERIFY" = "true" ]; then
    forge script script/DeployEnhanced.s.sol \
        --rpc-url $RPC_URL \
        --private-key $PRIVATE_KEY \
        --broadcast \
        --verify \
        --etherscan-api-key $EXPLORER_API_KEY \
        --via-ir
else
    forge script script/DeployEnhanced.s.sol \
        --rpc-url $RPC_URL \
        --private-key $PRIVATE_KEY \
        --broadcast \
        --via-ir
fi

echo -e "${GREEN}✅ Contracts deployed successfully${NC}"

# Get deployment addresses
echo -e "${YELLOW}Retrieving deployment addresses...${NC}"

# Read deployment addresses from broadcast files
BROADCAST_DIR="broadcast/DeployEnhanced.s.sol/$CHAIN_ID/run-latest.json"

if [ -f "$BROADCAST_DIR" ]; then
    echo -e "${BLUE}Deployment Summary:${NC}"
    echo "=================="
    
    # Extract addresses from broadcast file
    EIGENLVR_V2_ADDRESS=$(jq -r '.transactions[] | select(.contractName == "EigenLVR_V2") | .contractAddress' $BROADCAST_DIR)
    CROSS_CHAIN_MONITOR_ADDRESS=$(jq -r '.transactions[] | select(.contractName == "CrossChainPriceMonitor") | .contractAddress' $BROADCAST_DIR)
    PRIVATE_AUCTION_MANAGER_ADDRESS=$(jq -r '.transactions[] | select(.contractName == "PrivateAuctionManager") | .contractAddress' $BROADCAST_DIR)
    CHAIN_REGISTRY_ADDRESS=$(jq -r '.transactions[] | select(.contractName == "ChainRegistry") | .contractAddress' $BROADCAST_DIR)
    
    echo "EigenLVR_V2: $EIGENLVR_V2_ADDRESS"
    echo "CrossChainPriceMonitor: $CROSS_CHAIN_MONITOR_ADDRESS"
    echo "PrivateAuctionManager: $PRIVATE_AUCTION_MANAGER_ADDRESS"
    echo "ChainRegistry: $CHAIN_REGISTRY_ADDRESS"
    
    # Save addresses to file
    cat > deployed-contracts-$NETWORK.json << EOF
{
  "network": "$NETWORK",
  "chainId": $CHAIN_ID,
  "rpcUrl": "$RPC_URL",
  "explorerUrl": "$EXPLORER_URL",
  "contracts": {
    "EigenLVR_V2": "$EIGENLVR_V2_ADDRESS",
    "CrossChainPriceMonitor": "$CROSS_CHAIN_MONITOR_ADDRESS",
    "PrivateAuctionManager": "$PRIVATE_AUCTION_MANAGER_ADDRESS",
    "ChainRegistry": "$CHAIN_REGISTRY_ADDRESS"
  },
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    echo -e "${GREEN}✅ Deployment addresses saved to deployed-contracts-$NETWORK.json${NC}"
    
    # Display explorer links
    echo -e "${BLUE}Explorer Links:${NC}"
    echo "==============="
    echo "EigenLVR_V2: $EXPLORER_URL/address/$EIGENLVR_V2_ADDRESS"
    echo "CrossChainPriceMonitor: $EXPLORER_URL/address/$CROSS_CHAIN_MONITOR_ADDRESS"
    echo "PrivateAuctionManager: $EXPLORER_URL/address/$PRIVATE_AUCTION_MANAGER_ADDRESS"
    echo "ChainRegistry: $EXPLORER_URL/address/$CHAIN_REGISTRY_ADDRESS"
    
else
    echo -e "${RED}❌ Could not find deployment addresses${NC}"
fi

# Run post-deployment tests
echo -e "${YELLOW}Running post-deployment tests...${NC}"
forge test --via-ir --fork-url $RPC_URL --match-test testDeployment
echo -e "${GREEN}✅ Post-deployment tests passed${NC}"

# Display useful information
echo -e "${BLUE}🎉 Deployment Complete!${NC}"
echo "========================"
echo -e "${YELLOW}Network Information:${NC}"
echo "• Network: $NETWORK"
echo "• Chain ID: $CHAIN_ID"
echo "• RPC URL: $RPC_URL"
echo "• Explorer: $EXPLORER_URL"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Verify contracts on explorer"
echo "2. Test the contracts: forge test --fork-url $RPC_URL"
echo "3. Configure cross-chain monitoring"
echo "4. Set up EigenLayer AVS integration"
echo "5. Configure Fhenix FHE integration"
echo ""
echo -e "${GREEN}Happy testing! 🚀${NC}"
