# Remix IDE Deployment Guide

This guide walks you through deploying and verifying the DAO contracts using Remix IDE.

## Prerequisites

- MetaMask connected to Sepolia testnet
- Sepolia ETH for deployment
- Remix IDE open at https://remix.ethereum.org/

## Step 1: Prepare Contracts for Remix

The contracts need OpenZeppelin imports adjusted for Remix. Here are the correct imports:

### For DAOToken.sol
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
```

### For Treasury.sol
```solidity
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
```

### For VotingPowerEarner.sol
```solidity
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
```

### For DAOGovernor.sol
```solidity
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/interfaces/IERC5805.sol";
```

## Step 2: Configure Compiler

### Fix Contract Size Issue (IMPORTANT!)

The DAOGovernor contract exceeds the 24KB limit. To fix this:

1. Go to **Solidity Compiler** tab (left sidebar)
2. Select compiler version: **0.8.24**
3. Click **Advanced Configurations**
4. Enable **optimization**: ✅ checked
5. Set **runs** to: **200** (or lower like 100 for smaller size)
6. Click **Compile** for each contract

**Why this works:** The optimizer reduces bytecode size by removing redundant code and optimizing gas usage.

### Alternative: Use via-ir

If optimization alone doesn't work:
1. Enable **optimization**: ✅
2. Set **runs**: **200**
3. Enable **via-ir**: ✅ (this uses the new IR-based compiler)
4. Recompile

## Step 3: Deployment Order

Deploy contracts in this specific order (dependencies matter!):

### 1. Deploy DAOToken

**Contract:** `DAOToken.sol`

**Constructor Parameters:** None

**Steps:**
1. Select `DAOToken` from contract dropdown
2. Click **Deploy**
3. Confirm transaction in MetaMask
4. Copy deployed address: `0x...`

### 2. Deploy Treasury

**Contract:** `Treasury.sol`

**Constructor Parameters:** None

**Steps:**
1. Select `Treasury` from contract dropdown
2. Click **Deploy**
3. Confirm transaction
4. Copy deployed address: `0x...`

### 3. Deploy TimelockController

**Contract:** `TimelockController` (OpenZeppelin)

**Constructor Parameters:**
- `minDelay`: `172800` (2 days in seconds)
- `proposers`: `[]` (empty array - will add Governor later)
- `executors`: `["0x0000000000000000000000000000000000000000"]` (anyone can execute)
- `admin`: `YOUR_WALLET_ADDRESS`

**Steps:**
1. Select `TimelockController` from contract dropdown
2. Enter parameters:
   ```
   172800,[""],["0x0000000000000000000000000000000000000000"],"YOUR_ADDRESS"
   ```
3. Click **Deploy**
4. Confirm transaction
5. Copy deployed address: `0x...`

### 4. Deploy DAOGovernor

**Contract:** `DAOGovernor.sol`

**Constructor Parameters:**
- `_token`: `[DAOToken address from step 1]`
- `_timelock`: `[TimelockController address from step 3]`

**Steps:**
1. Select `DAOGovernor` from contract dropdown
2. Enter parameters:
   ```
   "0x[DAOToken_address]","0x[Timelock_address]"
   ```
3. Click **Deploy**
4. Confirm transaction
5. Copy deployed address: `0x...`

**If you get "contract size exceeds 24KB" error:**
- Make sure optimizer is enabled with runs=200
- Try runs=100 for even smaller size
- Enable via-ir if still too large
- Consider using Foundry instead (already deployed successfully)

### 5. Deploy VotingPowerEarner

**Contract:** `VotingPowerEarner.sol`

**Constructor Parameters:**
- `_daotoken`: `[DAOToken address from step 1]`
- `_epochDuration`: `604800` (1 week in seconds)
- `_treasuryAddress`: `[Treasury address from step 2]`

**Steps:**
1. Select `VotingPowerEarner` from contract dropdown
2. Enter parameters:
   ```
   "0x[DAOToken_address]",604800,"0x[Treasury_address]"
   ```
3. Click **Deploy**
4. Confirm transaction
5. Copy deployed address: `0x...`

## Step 4: Configure Permissions

After deployment, you need to set up permissions:

### 4.1 Add VotingPowerEarner as Minter

**On DAOToken contract:**
1. Go to **Deployed Contracts**
2. Expand `DAOToken`
3. Find `addMinter` function
4. Enter VotingPowerEarner address
5. Click **transact**
6. Confirm transaction

### 4.2 Transfer Treasury Ownership

**On Treasury contract:**
1. Expand `Treasury`
2. Find `transferOwnership` function
3. Enter TimelockController address
4. Click **transact**
5. Confirm transaction

**Note:** Treasury uses Ownable2Step, so ownership transfer is pending until accepted.

### 4.3 Grant Proposer Role to Governor

**On TimelockController contract:**
1. Expand `TimelockController`
2. Find `PROPOSER_ROLE` function (view)
3. Click to get the role hash: `0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1`
4. Find `grantRole` function
5. Enter:
   - `role`: `0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1`
   - `account`: `[DAOGovernor address]`
6. Click **transact**
7. Confirm transaction

## Step 5: Verify Contracts on Etherscan

For each deployed contract:

1. Go to contract address on Sepolia Etherscan
2. Click **Contract** tab
3. Click **Verify and Publish**
4. Select:
   - Compiler Type: **Solidity (Single file)**
   - Compiler Version: **v0.8.24**
   - License: **MIT**
5. Click **Continue**
6. Paste flattened contract code
7. If using optimizer:
   - Enable optimization: **Yes**
   - Runs: **200**
8. Click **Verify and Publish**

### Flatten Contracts in Remix

To get flattened code:
1. Right-click on contract file
2. Select **Flatten**
3. Copy the flattened code
4. Use for Etherscan verification

## Step 6: Test Deployment

### Test 1: Earn Voting Power

1. Go to VotingPowerEarner contract
2. Call `claimCheckIn()`
3. Verify you received 100 tokens on DAOToken

### Test 2: Delegate Votes

1. Go to DAOToken contract
2. Call `delegate(YOUR_ADDRESS)`
3. Call `getVotes(YOUR_ADDRESS)` to verify

### Test 3: Check Configuration

Verify these values on DAOGovernor:
- `votingDelay()` = 1
- `votingPeriod()` = 259200
- `proposalThreshold()` = 500
- `quorum(0)` = 40000

## Troubleshooting

### Contract Size Too Large

**Error:** "Contract code size exceeds 24576 bytes"

**Solutions:**
1. Enable optimizer with runs=200
2. Try runs=100 or even 50
3. Enable via-ir compilation
4. Remove unnecessary comments
5. Use Foundry instead (already successfully deployed)

### Import Errors

**Error:** "File import callback not supported"

**Solution:** Use `@openzeppelin/contracts/...` imports (Remix auto-resolves these)

### Constructor Parameter Errors

**Error:** "Invalid parameters"

**Solution:** 
- Use double quotes for addresses: `"0x..."`
- Use square brackets for arrays: `["0x..."]`
- Separate parameters with commas
- No spaces in parameter string

### Transaction Fails

**Error:** "Transaction reverted"

**Solutions:**
1. Check you have enough Sepolia ETH
2. Verify constructor parameters are correct
3. Check gas limit is sufficient
4. Review error message in MetaMask

## Already Deployed Contracts

You already have successfully deployed contracts on Sepolia:

```
DAOToken:          0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00
VotingPowerEarner: 0xAE63F4eD016B57E03E65c1f7a3569A8e807E7B6F
Treasury:          0x896FAdfc6aD2f7856176CBD92474629C3320C909
TimelockController: 0x1E6b8e878E5d3E4a3869839941A591D9697cF246
DAOGovernor:       0x97fE800648c002F456718F7F332cC394AdD96f61
```

**Recommendation:** Instead of redeploying, just verify these existing contracts on Etherscan using the flattened source code.

## Verification Using Foundry (Easier!)

Since you already deployed with Foundry, you can verify using:

```bash
wsl bash -c "cd '/mnt/c/Users/malon/Web3 Development/Portfolio_Projects/DAO-treasury' && source .env && ~/.foundry/bin/forge verify-contract 0x97fE800648c002F456718F7F332cC394AdD96f61 src/DAOGovernor.sol:DAOGovernor --chain sepolia --etherscan-api-key \$ETHERSCAN_API_KEY --constructor-args \$(cast abi-encode 'constructor(address,address)' 0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00 0x1E6b8e878E5d3E4a3869839941A591D9697cF246)"
```

This is much easier than redeploying!

## Summary

1. ✅ Enable optimizer (runs=200) to fix size issue
2. ✅ Deploy in correct order
3. ✅ Configure permissions
4. ✅ Verify on Etherscan
5. ✅ Test functionality

**Recommended:** Use Foundry verification for existing contracts instead of redeploying.
