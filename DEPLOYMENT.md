# DAO Deployment Guide

## Prerequisites

1. **Install Foundry** (if not already installed):
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Get Sepolia ETH**:
   - Visit [Sepolia Faucet](https://sepoliafaucet.com/) or [Alchemy Faucet](https://sepoliafaucet.com/)
   - Get test ETH for your deployment address

3. **Setup Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

## Deployment Steps

### 1. Run Tests
```bash
forge test -vv
```

### 2. Deploy to Sepolia
```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### 3. Verify Deployment
Check `deployed-addresses.txt` for contract addresses.

## Contract Addresses (Example)
After deployment, you'll get addresses like:
```
DAO_TOKEN=0x1234...
TREASURY=0x5678...
TIMELOCK=0x9abc...
GOVERNOR=0xdef0...
EARNER=0x1357...
```

## Tally Integration

### 1. Add Governor to Tally
1. Go to [Tally.xyz](https://www.tally.xyz/)
2. Click "Add a DAO"
3. Enter your Governor contract address
4. Select Sepolia network
5. Follow the setup wizard

### 2. Configure DAO Settings
- **Name**: Participation DAO
- **Description**: A DAO where voting power is earned through participation
- **Voting Token**: Your DAO Token address
- **Governor**: Your Governor address

### 3. Test Proposal Flow
1. **Earn Voting Power**:
   ```solidity
   // Call claimCheckIn() on VotingPowerEarner
   // Or fundTreasury() with ETH
   ```

2. **Delegate Votes** (if needed):
   ```solidity
   // Call delegate() on DAO Token
   ```

3. **Create Proposal** on Tally:
   - Target: Treasury contract
   - Function: `releaseETH(address,uint256)`
   - Parameters: recipient address, amount in wei

4. **Vote** on Tally interface

5. **Queue & Execute** after voting period

## Configuration Parameters

### Governor Settings
- **Voting Delay**: 1 block (~12 seconds)
- **Voting Period**: 259,200 blocks (~3 days)
- **Proposal Threshold**: 500 tokens
- **Quorum**: 40,000 votes

### Timelock Settings
- **Min Delay**: 2 days (172,800 seconds)

### Earning Parameters
- **Epoch Duration**: 1 week (604,800 seconds)
- **Check-in Points**: 100 per epoch
- **User Cap**: 500 points per epoch
- **Global Cap**: 100,000 points per epoch
- **ETH Rate**: 1000 points per ETH

## Testing Locally

### Run Full Test Suite
```bash
forge test --match-contract DAOIntegrationTest -vvv
```

### Test Individual Components
```bash
forge test --match-contract DAOTokenTest -vv
forge test --match-contract VotingPowerEarnerTest -vv
forge test --match-contract TreasuryTest -vv
```

## Security Considerations

1. **Access Control**: Only VotingPowerEarner can mint tokens
2. **Non-transferable**: Tokens can only be minted/burned, not transferred
3. **Timelock Protection**: All treasury operations go through 2-day timelock
4. **Pausable**: Earning can be paused in emergencies
5. **Caps**: Per-user and global caps prevent abuse

## Troubleshooting

### Common Issues

1. **"Insufficient funds"**: Make sure you have enough Sepolia ETH
2. **"Nonce too high"**: Reset your wallet nonce or wait
3. **"Contract not verified"**: Add `--verify` flag and check Etherscan API key

### Verification Commands
```bash
# Verify individual contracts if auto-verification fails
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> --chain sepolia
```

## Next Steps

1. Deploy to Sepolia testnet
2. Add to Tally.xyz
3. Test full proposal lifecycle
4. Document results in README.md
5. Submit assignment with:
   - Contract addresses
   - Tally proposal URL
   - Execution transaction hash
   - Before/after state verification