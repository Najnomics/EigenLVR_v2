# EigenLVR v2 Makefile
# Comprehensive development workflow automation

.PHONY: help install build test test-verbose test-gas coverage format lint clean deploy-anvil start-anvil stop-anvil status dev

# Colors for output
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
NC=\033[0m # No Color

# Default target
help:
	@echo "$(GREEN)EigenLVR v2 Development Commands$(NC)"
	@echo "=================================="
	@echo "$(BLUE)Setup:$(NC)"
	@echo "  make install          Install all dependencies"
	@echo "  make build           Build all contracts"
	@echo ""
	@echo "$(BLUE)Testing:$(NC)"
	@echo "  make test            Run all tests"
	@echo "  make test-verbose    Run tests with verbose output"
	@echo "  make test-gas        Run tests with gas reporting"
	@echo "  make coverage        Generate coverage report"
	@echo ""
	@echo "$(BLUE)Development:$(NC)"
	@echo "  make format          Format all Solidity files"
	@echo "  make lint            Run linter on contracts"
	@echo "  make clean           Clean build artifacts"
	@echo "  make dev             Start development environment"
	@echo ""
	@echo "$(BLUE)Deployment:$(NC)"
	@echo "  make start-anvil     Start local Anvil blockchain"
	@echo "  make deploy-anvil    Deploy to Anvil"
	@echo "  make deploy-testnet  Deploy to testnet (Sepolia)"
	@echo "  make deploy-mainnet  Deploy to mainnet"
	@echo "  make stop-anvil      Stop Anvil blockchain"
	@echo ""
	@echo "$(BLUE)Utils:$(NC)"
	@echo "  make status          Show project status"

# Installation
install:
	@echo "$(GREEN)Installing dependencies...$(NC)"
	@pnpm install
	@forge install --no-commit
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

# Building
build:
	@echo "$(GREEN)Building contracts...$(NC)"
	@forge build --via-ir
	@echo "$(GREEN)✅ Contracts built$(NC)"

# Testing
test:
	@echo "$(GREEN)Running tests...$(NC)"
	@forge test --via-ir
	@echo "$(GREEN)✅ Tests completed$(NC)"

test-verbose:
	@echo "$(GREEN)Running tests with verbose output...$(NC)"
	@forge test --via-ir -vvv

test-gas:
	@echo "$(GREEN)Running tests with gas reporting...$(NC)"
	@forge test --via-ir --gas-report

coverage:
	@echo "$(GREEN)Generating coverage report...$(NC)"
	@forge coverage --via-ir --ir-minimum
	@echo "$(GREEN)✅ Coverage report generated$(NC)"

# Code quality
format:
	@echo "$(GREEN)Formatting Solidity files...$(NC)"
	@forge fmt
	@echo "$(GREEN)✅ Code formatted$(NC)"

lint:
	@echo "$(GREEN)Checking code formatting...$(NC)"
	@forge fmt --check
	@echo "$(GREEN)✅ Code formatting verified$(NC)"

# Cleanup
clean:
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	@rm -rf out/
	@rm -rf cache/
	@rm -rf cache_forge/
	@echo "$(GREEN)✅ Artifacts cleaned$(NC)"

# Anvil deployment
start-anvil:
	@echo "$(GREEN)Starting Anvil blockchain...$(NC)"
	@anvil --host 0.0.0.0 --port 8545 --chain-id 31337 &
	@sleep 2
	@echo "$(GREEN)✅ Anvil started on localhost:8545$(NC)"

stop-anvil:
	@echo "$(GREEN)Stopping Anvil blockchain...$(NC)"
	@pkill -f "anvil" || true
	@echo "$(GREEN)✅ Anvil stopped$(NC)"

deploy-anvil: build
	@echo "$(GREEN)Deploying to Anvil...$(NC)"
	@forge script script/DeployAnvil.s.sol \
		--rpc-url http://localhost:8545 \
		--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
		--broadcast \
		--via-ir
	@echo "$(GREEN)✅ Deployed to Anvil$(NC)"

# Development workflow
dev: clean install build test start-anvil deploy-anvil
	@echo "$(GREEN)🚀 Development environment ready!$(NC)"
	@echo "$(BLUE)Anvil running on: http://localhost:8545$(NC)"
	@echo "$(BLUE)Chain ID: 31337$(NC)"
	@echo "$(BLUE)Test account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266$(NC)"

# Status check
status:
	@echo "$(GREEN)EigenLVR v2 Project Status$(NC)"
	@echo "=========================="
	@echo "$(BLUE)Git Status:$(NC)"
	@git status --porcelain || echo "Not a git repository"
	@echo ""
	@echo "$(BLUE)Dependencies:$(NC)"
	@if [ -f "package.json" ]; then echo "✅ Node.js dependencies configured"; else echo "❌ package.json missing"; fi
	@if [ -d "node_modules" ]; then echo "✅ Node.js modules installed"; else echo "❌ Run 'make install'"; fi
	@if [ -d "lib" ]; then echo "✅ Foundry dependencies installed"; else echo "❌ Run 'make install'"; fi
	@echo ""
	@echo "$(BLUE)Build Status:$(NC)"
	@if [ -d "out" ]; then echo "✅ Contracts compiled"; else echo "❌ Run 'make build'"; fi
	@echo ""
	@echo "$(BLUE)Source Files:$(NC)"
	@find src -name "*.sol" | wc -l | xargs echo "Solidity files:"
	@find test -name "*.sol" 2>/dev/null | wc -l | xargs echo "Test files:" || echo "Test files: 0"
	@echo ""
	@echo "$(BLUE)Key Components:$(NC)"
	@if [ -f "src/EigenLVR_Universal.sol" ]; then echo "✅ Main Hook Contract"; else echo "❌ Main Hook Missing"; fi
	@if [ -f "src/crosschain/CrossChainLVRDetector.sol" ]; then echo "✅ Cross-chain Detection"; else echo "❌ Cross-chain Missing"; fi
	@if [ -f "src/privacy/PrivateAuctionManager.sol" ]; then echo "✅ FHE Private Auctions"; else echo "❌ FHE Component Missing"; fi

# Advanced testing
test-specific:
	@echo "$(GREEN)Running specific test...$(NC)"
	@if [ -z "$(TEST)" ]; then echo "$(RED)Usage: make test-specific TEST=testFunction$(NC)"; exit 1; fi
	@forge test --via-ir --match-test $(TEST) -vvv

test-contract:
	@echo "$(GREEN)Running tests for specific contract...$(NC)"
	@if [ -z "$(CONTRACT)" ]; then echo "$(RED)Usage: make test-contract CONTRACT=EigenLVR_Universal$(NC)"; exit 1; fi
	@forge test --via-ir --match-contract $(CONTRACT) -vvv

# Gas profiling
gas-snapshot:
	@echo "$(GREEN)Creating gas snapshot...$(NC)"
	@forge snapshot --via-ir
	@echo "$(GREEN)✅ Gas snapshot saved to .gas-snapshot$(NC)"

# CI/CD helpers
ci-check: install build test coverage lint
	@echo "$(GREEN)✅ All CI checks passed$(NC)"

# Debug helpers
debug-build:
	@echo "$(GREEN)Building with debug info...$(NC)"
	@forge build --via-ir --force

debug-test:
	@echo "$(GREEN)Running tests in debug mode...$(NC)"
	@if [ -z "$(TEST)" ]; then echo "$(RED)Usage: make debug-test TEST=testFunction$(NC)"; exit 1; fi
	@forge test --via-ir --match-test $(TEST) -vvvv --debug

# Deployment helpers
deploy-sepolia:
	@echo "$(GREEN)Deploying to Sepolia testnet...$(NC)"
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "$(RED)Set PRIVATE_KEY environment variable$(NC)"; exit 1; fi
	@forge script script/DeployEnhanced.s.sol \
		--rpc-url https://sepolia.infura.io/v3/$(INFURA_KEY) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--via-ir

deploy-testnet: deploy-sepolia
	@echo "$(GREEN)✅ Testnet deployment completed$(NC)"

deploy-mainnet:
	@echo "$(GREEN)Deploying to Ethereum mainnet...$(NC)"
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "$(RED)Set PRIVATE_KEY environment variable$(NC)"; exit 1; fi
	@forge script script/DeployEnhanced.s.sol \
		--rpc-url https://mainnet.infura.io/v3/$(INFURA_KEY) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--via-ir \
		--slow
	@echo "$(GREEN)✅ Mainnet deployment completed$(NC)"

# Documentation
docs:
	@echo "$(GREEN)Generating documentation...$(NC)"
	@forge doc
	@echo "$(GREEN)✅ Documentation generated in docs/$(NC)"

# Security
security-check:
	@echo "$(GREEN)Running security checks...$(NC)"
	@if command -v slither >/dev/null 2>&1; then \
		slither .; \
	else \
		echo "$(RED)Slither not installed. Install with: pip install slither-analyzer$(NC)"; \
	fi