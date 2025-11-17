#!/bin/bash

# Simple script to verify a single contract
# Usage: ./verify-single-contract.sh <contract_name>
# Example: ./verify-single-contract.sh DAOGovernor

source .env

case $1 in
  "DAOToken")
    echo "Verifying DAOToken..."
    ~/.foundry/bin/forge verify-contract \
      0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00 \
      src/DaoToken.sol:DAOToken \
      --chain sepolia \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      --watch
    ;;
    
  "Treasury")
    echo "Verifying Treasury..."
    ~/.foundry/bin/forge verify-contract \
      0x896FAdfc6aD2f7856176CBD92474629C3320C909 \
      src/Treasury.sol:Treasury \
      --chain sepolia \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      --watch
    ;;
    
  "VotingPowerEarner")
    echo "Verifying VotingPowerEarner..."
    ~/.foundry/bin/forge verify-contract \
      0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F \
      src/VotingPowerEarner.sol:VotingPowerEarner \
      --chain sepolia \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      --constructor-args $(cast abi-encode "constructor(address,uint256,address)" 0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00 604800 0x896FAdfc6aD2f7856176CBD92474629C3320C909) \
      --watch
    ;;
    
  "DAOGovernor")
    echo "Verifying DAOGovernor..."
    ~/.foundry/bin/forge verify-contract \
      0x97fE800648c002F456718F7F332cC394AdD96f61 \
      src/DAOGovernor.sol:DAOGovernor \
      --chain sepolia \
      --etherscan-api-key $ETHERSCAN_API_KEY \
      --constructor-args $(cast abi-encode "constructor(address,address)" 0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00 0x1E6b8e878E5d3E4a3869839941A591D9697cF246) \
      --watch
    ;;
    
  *)
    echo "Usage: ./verify-single-contract.sh <contract_name>"
    echo ""
    echo "Available contracts:"
    echo "  DAOToken"
    echo "  Treasury"
    echo "  VotingPowerEarner"
    echo "  DAOGovernor"
    echo ""
    echo "Example: ./verify-single-contract.sh DAOGovernor"
    ;;
esac
