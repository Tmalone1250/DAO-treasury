# DAO Project Makefile

# Load environment variables
include .env
export

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make install     - Install dependencies"
	@echo "  make build       - Build contracts"
	@echo "  make test        - Run all tests"
	@echo "  make test-unit   - Run unit tests only"
	@echo "  make test-integration - Run integration tests"
	@echo "  make deploy-sepolia - Deploy to Sepolia testnet"
	@echo "  make verify      - Verify contracts on Etherscan"
	@echo "  make clean       - Clean build artifacts"

# Install dependencies
.PHONY: install
install:
	forge install

# Build contracts
.PHONY: build
build:
	forge build

# Run all tests
.PHONY: test
test:
	forge test -vv

# Run unit tests only
.PHONY: test-unit
test-unit:
	forge test --match-contract "DAOTokenTest|VotingPowerEarnerTest|TreasuryTest" -vv

# Run integration tests
.PHONY: test-integration
test-integration:
	forge test --match-contract "DAOIntegrationTest" -vvv

# Deploy to Sepolia
.PHONY: deploy-sepolia
deploy-sepolia:
	@echo "Deploying to Sepolia testnet..."
	~/.foundry/bin/forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

# Deploy without verification (faster)
.PHONY: deploy-sepolia-fast
deploy-sepolia-fast:
	@echo "Deploying to Sepolia testnet (no verification)..."
	~/.foundry/bin/forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast

# Verify contracts (if deployment verification failed)
.PHONY: verify
verify:
	@echo "Verify contracts manually using addresses from deployed-addresses.txt"

# Clean build artifacts
.PHONY: clean
clean:
	forge clean

# Gas report
.PHONY: gas-report
gas-report:
	forge test --gas-report

# Coverage report
.PHONY: coverage
coverage:
	forge coverage

# Format code
.PHONY: format
format:
	forge fmt

# Check code formatting
.PHONY: format-check
format-check:
	forge fmt --check

# Lint code
.PHONY: lint
lint:
	forge fmt --check

# Local development setup
.PHONY: setup
setup: install build test
	@echo "Setup complete! Ready for development."

# Quick deployment check (dry run)
.PHONY: deploy-check
deploy-check:
	forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL)

# Run specific test
test-%:
	forge test --match-contract $* -vvv