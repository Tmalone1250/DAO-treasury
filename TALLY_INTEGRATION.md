# Tally Integration Guide

This guide walks you through integrating your deployed DAO with Tally for governance management.

## Prerequisites

- DAO contracts deployed on Sepolia testnet
- Sepolia ETH for transactions
- Wallet with voting power (earned through participation)

## Contract Addresses

- **Governor:** `0x97fE800648c002F456718F7F332cC394AdD96f61`
- **Token:** `0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00`
- **Timelock:** `0x1E6b8e878E5d3E4a3869839941A591D9697cF246`
- **Network:** Sepolia (Chain ID: 11155111)

## Step 1: Earn Voting Power

Before you can participate in governance, you need to earn voting power.

### Option A: Claim Check-in (100 points)

1. Go to [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F#writeContract)
2. Connect your wallet
3. Find the `claimCheckIn` function
4. Click "Write" to execute
5. Confirm the transaction

### Option B: Fund Treasury (1000 points per ETH)

1. Go to [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F#writeContract)
2. Connect your wallet
3. Find the `fundTreasury` function
4. Enter ETH amount (e.g., 0.5 for 500 points)
5. Click "Write" to execute
6. Confirm the transaction

**Note:** You can earn up to 500 points per epoch (1 week). The current epoch resets every 7 days.

## Step 2: Delegate Voting Power

You must delegate your voting power to yourself (or another address) before you can vote.

1. Go to [DAOToken on Etherscan](https://sepolia.etherscan.io/address/0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00#writeContract)
2. Connect your wallet
3. Find the `delegate` function
4. Enter your wallet address (to delegate to yourself)
5. Click "Write" to execute
6. Confirm the transaction

**Important:** Delegation must be done before the proposal is created for your votes to count!

## Step 3: Add DAO to Tally

1. Visit [Tally.xyz](https://www.tally.xyz/)
2. Click "Add a DAO" or "Create DAO"
3. Select "Import existing DAO"
4. Enter the following information:
   - **Network:** Sepolia
   - **Governor Address:** `0x97fE800648c002F456718F7F332cC394AdD96f61`
5. Tally will automatically detect:
   - Token address
   - Timelock address
   - Governance parameters
6. Complete the DAO profile:
   - **Name:** Participation DAO
   - **Description:** A DAO where voting power is earned through active participation
   - **Logo:** (optional)
   - **Website:** (optional)
7. Submit and wait for Tally to index your DAO

## Step 4: Verify DAO Configuration

Once added, verify the following on Tally:

- ✅ Token is recognized: DAO Token (DTK)
- ✅ Voting delay: 1 block
- ✅ Voting period: 259,200 blocks
- ✅ Proposal threshold: 500 tokens
- ✅ Quorum: 40,000 votes
- ✅ Timelock delay: 2 days

## Step 5: Create a Test Proposal

### Requirements
- At least 500 voting tokens
- Voting power delegated to yourself
- Wait at least 1 block after delegation

### Example Proposal: Release ETH from Treasury

1. Go to your DAO on Tally
2. Click "Create Proposal"
3. Fill in proposal details:
   - **Title:** "Release 0.1 ETH to Test Address"
   - **Description:** "This is a test proposal to verify the governance workflow"
4. Add action:
   - **Target Contract:** `0x896FAdfc6aD2f7856176CBD92474629C3320C909` (Treasury)
   - **Function:** `releaseETH`
   - **Parameters:**
     - `recipient (address payable)`: Your test address
     - `amount (uint256)`: `100000000000000000` (0.1 ETH in wei)
5. Review and submit proposal
6. Confirm transaction in your wallet

### Example Proposal: Update Treasury Parameter

1. Create proposal on Tally
2. Add action:
   - **Target Contract:** `0x896FAdfc6aD2f7856176CBD92474629C3320C909` (Treasury)
   - **Function:** `setManagedParameter`
   - **Parameters:**
     - `newValue (uint256)`: `200`
3. Submit proposal

## Step 6: Vote on Proposal

1. Wait for voting delay to pass (1 block, ~12 seconds)
2. Go to the proposal page on Tally
3. Click "Vote"
4. Select your vote: For / Against / Abstain
5. Optionally add a reason
6. Submit vote
7. Confirm transaction

**Note:** You need at least 40,000 total votes FOR the proposal to meet quorum. For testing, you may need to create multiple accounts or adjust the quorum.

## Step 7: Queue Proposal

After the voting period ends (259,200 blocks):

1. If proposal passed and met quorum, click "Queue"
2. Confirm transaction
3. Proposal enters timelock delay (2 days)

## Step 8: Execute Proposal

After timelock delay (2 days):

1. Click "Execute" on Tally
2. Confirm transaction
3. Proposal actions are executed
4. Verify state changes on Etherscan

## Verification Checklist

After executing a proposal, verify:

- [ ] Transaction succeeded on Etherscan
- [ ] Treasury balance changed (if ETH was released)
- [ ] Parameter updated (if parameter was changed)
- [ ] Events emitted correctly
- [ ] DAO state updated on Tally

## Troubleshooting

### "Insufficient voting power"
- Ensure you've earned voting power through check-in or treasury funding
- Verify you've delegated to yourself
- Check your balance on Etherscan

### "Proposal threshold not met"
- You need at least 500 tokens to create a proposal
- Earn more voting power or wait for next epoch

### "Quorum not reached"
- Proposal needs 40,000 votes to pass
- For testing, consider:
  - Creating multiple test accounts
  - Having others participate
  - Deploying with lower quorum for testing

### "Proposal not executable"
- Ensure voting period has ended
- Verify proposal was queued
- Check that timelock delay (2 days) has passed

### "Transaction reverted"
- Check that target contract has sufficient balance
- Verify function parameters are correct
- Ensure timelock has proper permissions

## Example Transaction Flow

1. **Earn Voting Power:** [Transaction Hash]
2. **Delegate Votes:** [Transaction Hash]
3. **Create Proposal:** [Transaction Hash]
4. **Cast Vote:** [Transaction Hash]
5. **Queue Proposal:** [Transaction Hash]
6. **Execute Proposal:** [Transaction Hash]

## Useful Commands

### Check Your Voting Power
```solidity
// On DAOToken contract
getVotes(yourAddress)
```

### Check Current Epoch
```solidity
// On VotingPowerEarner contract
currentEpoch()
```

### Check Remaining Cap
```solidity
// On VotingPowerEarner contract
remainingUserCap(yourAddress)
```

### Check if Check-in Claimed
```solidity
// On VotingPowerEarner contract
claimedCheckIn(yourAddress)
```

## Resources

- **Tally Documentation:** https://docs.tally.xyz/
- **OpenZeppelin Governor:** https://docs.openzeppelin.com/contracts/4.x/governance
- **Sepolia Etherscan:** https://sepolia.etherscan.io/
- **Sepolia Faucet:** https://sepoliafaucet.com/

## Next Steps

1. Complete Tally integration
2. Create and execute test proposal
3. Document results with transaction hashes
4. Update README.md with Tally URL
5. Share DAO with community for testing

---

**Status:** Ready for Tally integration  
**Last Updated:** November 9, 2025
