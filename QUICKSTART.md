# Quick Start Guide

Get started with the Participation DAO in 5 minutes!

## What is Participation DAO?

A DAO where you earn voting power by participating, not by buying tokens. Contribute to the treasury or check in regularly to earn influence in governance decisions.

## Prerequisites

- MetaMask or another Web3 wallet
- Sepolia testnet ETH ([Get from faucet](https://sepoliafaucet.com/))
- 5 minutes of your time

## Step 1: Earn Your First Voting Power (2 minutes)

### Option A: Quick Check-in (100 points)

1. Go to [VotingPowerEarner on Etherscan](https://sepolia.etherscan.io/address/0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F#writeContract)
2. Click "Connect to Web3"
3. Find function `1. claimCheckIn`
4. Click "Write"
5. Confirm transaction
6. ✅ You earned 100 voting points!

### Option B: Fund Treasury (500 points)

1. Go to [VotingPowerEarner on Etherscan](https://sepolia.etherscan.io/address/0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F#writeContract)
2. Click "Connect to Web3"
3. Find function `2. fundTreasury`
4. Enter `0.5` in the payableAmount field
5. Click "Write"
6. Confirm transaction
7. ✅ You earned 500 voting points!

## Step 2: Activate Your Voting Power (1 minute)

You must delegate to yourself to activate your voting power:

1. Go to [DAOToken on Etherscan](https://sepolia.etherscan.io/address/0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00#writeContract)
2. Click "Connect to Web3"
3. Find function `2. delegate`
4. Enter your wallet address
5. Click "Write"
6. Confirm transaction
7. ✅ Your voting power is now active!

## Step 3: Check Your Voting Power (30 seconds)

1. Go to [DAOToken on Etherscan](https://sepolia.etherscan.io/address/0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00#readContract)
2. Find function `7. getVotes`
3. Enter your wallet address
4. Click "Query"
5. See your voting power!

## Step 4: Participate in Governance (On Tally)

Once the DAO is added to Tally:

1. Visit the DAO on [Tally.xyz](https://www.tally.xyz/)
2. Browse active proposals
3. Vote on proposals you care about
4. Create your own proposals (need 500+ tokens)

## Understanding the System

### Earning Caps
- **Per User:** 500 points per epoch (1 week)
- **Global:** 100,000 points per epoch
- **Check-in:** Once per epoch

### Earning Methods
| Method | Points | Frequency |
|--------|--------|-----------|
| Check-in | 100 | Once per epoch |
| Fund Treasury | 1000 per ETH | Up to cap |

### Governance Parameters
| Parameter | Value |
|-----------|-------|
| Proposal Threshold | 500 tokens |
| Quorum | 40,000 votes |
| Voting Period | ~3 days |
| Timelock Delay | 2 days |

## Common Questions

### How often can I earn points?
Every epoch (1 week). Check-in once per epoch, or fund treasury up to 500 points total.

### When can I vote?
Immediately after delegating! Just wait 1 block (~12 seconds).

### How do I create a proposal?
You need at least 500 tokens. Then create proposals on Tally to:
- Release funds from treasury
- Update DAO parameters
- Execute any on-chain action

### Can I transfer my tokens?
No! Tokens are non-transferable to prevent vote buying. You must earn them through participation.

### What happens to my tokens after an epoch?
They stay with you! Tokens don't expire, only the earning caps reset each epoch.

## Contract Addresses

Quick reference for interacting with the DAO:

```
VotingPowerEarner: 0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F
DAOToken:          0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00
Treasury:          0x896FAdfc6aD2f7856176CBD92474629C3320C909
Governor:          0x97fE800648c002F456718F7F332cC394AdD96f61
Timelock:          0x1E6b8e878E5d3E4a3869839941A591D9697cF246
```

## Useful Links

- **Sepolia Etherscan:** https://sepolia.etherscan.io/
- **Get Sepolia ETH:** https://sepoliafaucet.com/
- **Tally:** https://www.tally.xyz/
- **Full Documentation:** [README.md](README.md)

## Need Help?

- Check [TALLY_INTEGRATION.md](TALLY_INTEGRATION.md) for detailed Tally guide
- Review [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) for technical details
- Verify transactions on [Sepolia Etherscan](https://sepolia.etherscan.io/)

## Example Workflow

1. **Week 1:** Claim check-in (100 points) + Fund 0.4 ETH (400 points) = 500 points
2. **Delegate** to yourself
3. **Vote** on active proposals
4. **Week 2:** Claim check-in again (100 more points)
5. **Create** your own proposal (if you have 500+ tokens)
6. **Repeat** weekly to build influence

---

**Ready to participate?** Start with Step 1 above! 🚀

**Network:** Sepolia Testnet  
**Status:** Live and ready for testing
