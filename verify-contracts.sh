#!/bin/bash

# Contract Verification Script for Sepolia
# Run this script to verify all deployed contracts on Etherscan

echo "Verifying contracts on Sepolia Etherscan..."
echo ""

# Load environment variables
source .env

# Contract addresses
DAO_TOKEN="0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00"
TREASURY="0x896FAdfc6aD2f7856176CBD92474629C3320C909"
TIMELOCK="0x1E6b8e878E5d3E4a3869839941A591D9697cF246"
GOVERNOR="0x97fE800648c002F456718F7F332cC394AdD96f61"
EARNER="0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F"

echo "1. Verifying DAOToken..."
~/.foundry/bin/forge verify-contract \
  $DAO_TOKEN \
  src/DaoToken.sol:DAOToken \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch

echo ""
echo "2. Verifying Treasury..."
~/.foundry/bin/forge verify-contract \
  $TREASURY \
  src/Treasury.sol:Treasury \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch

echo ""
echo "3. Verifying TimelockController..."
echo "Note: TimelockController is from OpenZeppelin and may already be verified"
~/.foundry/bin/forge verify-contract \
  $TIMELOCK \
  lib/openzeppelin-contracts/contracts/governance/TimelockController.sol:TimelockController \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(uint256,address[],address[],address)" 172800 "[]" "[]" "0xd83B5031506039893BF1C827b0A79aDDee71E1fE") \
  --watch

echo ""
echo "4. Verifying DAOGovernor..."
~/.foundry/bin/forge verify-contract \
  $GOVERNOR \
  src/DAOGovernor.sol:DAOGovernor \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,address)" $DAO_TOKEN $TIMELOCK) \
  --watch

echo ""
echo "5. Verifying VotingPowerEarner..."
~/.foundry/bin/forge verify-contract \
  $EARNER \
  src/VotingPowerEarner.sol:VotingPowerEarner \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,uint256,address)" $DAO_TOKEN 604800 $TREASURY) \
  --watch

echo ""
echo "Verification complete!"
echo "Check contracts on Etherscan:"
echo "- DAOToken: https://sepolia.etherscan.io/address/$DAO_TOKEN"
echo "- Treasury: https://sepolia.etherscan.io/address/$TREASURY"
echo "- Timelock: https://sepolia.etherscan.io/address/$TIMELOCK"
echo "- Governor: https://sepolia.etherscan.io/address/$GOVERNOR"
echo "- Earner: https://sepolia.etherscan.io/address/$EARNER"
