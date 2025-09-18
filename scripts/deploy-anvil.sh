#!/bin/bash

# EigenLVR v2 - Anvil Deployment Script
# Deploys contracts to local Anvil blockchain for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ANVIL_RPC_URL="http://localhost:8545"
ANVIL_CHAIN_ID=31337
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
ACCOUNT="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

echo -e "${BLUE}🚀 EigenLVR v2 - Anvil Deployment${NC}"
echo "=================================="

# Check if Anvil is running
echo -e "${YELLOW}Checking if Anvil is running...${NC}"
if ! curl -s $ANVIL_RPC_URL > /dev/null; then
    echo -e "${RED}❌ Anvil is not running. Please start Anvil first:${NC}"
    echo "   anvil --host 0.0.0.0 --port 8545 --chain-id 31337"
    exit 1
fi
echo -e "${GREEN}✅ Anvil is running${NC}"

# Check if contracts are built
echo -e "${YELLOW}Checking if contracts are built...${NC}"
if [ ! -d "out" ]; then
    echo -e "${YELLOW}Building contracts...${NC}"
    forge build --via-ir
fi
echo -e "${GREEN}✅ Contracts are built${NC}"

# Deploy contracts
echo -e "${YELLOW}Deploying contracts to Anvil...${NC}"
forge script script/DeployEnhanced.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --via-ir

echo -e "${GREEN}✅ Contracts deployed successfully${NC}"

# Get deployment addresses
echo -e "${YELLOW}Retrieving deployment addresses...${NC}"

# Read deployment addresses from broadcast files
BROADCAST_DIR="broadcast/DeployEnhanced.s.sol/$ANVIL_CHAIN_ID/run-latest.json"

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
    cat > deployed-contracts-anvil.json << EOF
{
  "network": "anvil",
  "chainId": $ANVIL_CHAIN_ID,
  "rpcUrl": "$ANVIL_RPC_URL",
  "deployer": "$ACCOUNT",
  "contracts": {
    "EigenLVR_V2": "$EIGENLVR_V2_ADDRESS",
    "CrossChainPriceMonitor": "$CROSS_CHAIN_MONITOR_ADDRESS",
    "PrivateAuctionManager": "$PRIVATE_AUCTION_MANAGER_ADDRESS",
    "ChainRegistry": "$CHAIN_REGISTRY_ADDRESS"
  },
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    echo -e "${GREEN}✅ Deployment addresses saved to deployed-contracts-anvil.json${NC}"
else
    echo -e "${RED}❌ Could not find deployment addresses${NC}"
fi

# Run basic tests
echo -e "${YELLOW}Running basic tests...${NC}"
forge test --via-ir --fork-url $ANVIL_RPC_URL --match-test testBasic

echo -e "${GREEN}✅ Basic tests passed${NC}"

# Display useful information
echo -e "${BLUE}🎉 Deployment Complete!${NC}"
echo "========================"
echo -e "${YELLOW}Useful Information:${NC}"
echo "• RPC URL: $ANVIL_RPC_URL"
echo "• Chain ID: $ANVIL_CHAIN_ID"
echo "• Test Account: $ACCOUNT"
echo "• Private Key: $PRIVATE_KEY"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Test the contracts: forge test --fork-url $ANVIL_RPC_URL"
echo "2. Interact with contracts using cast or your preferred tool"
echo "3. Check deployment addresses in deployed-contracts-anvil.json"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
