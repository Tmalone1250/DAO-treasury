# Tally Integration Checklist

Use this checklist to complete the Tally integration and test the full governance workflow.

## Pre-Integration Setup

- [x] All contracts deployed to Sepolia
- [x] Permissions configured correctly
- [x] Documentation created
- [ ] Contracts verified on Etherscan (run `verify-contracts.sh`)

## Phase 1: Earn Voting Power

### User 1 (Proposer)
- [ ] Get Sepolia ETH from faucet
- [ ] Claim check-in on VotingPowerEarner (100 points)
- [ ] Fund treasury with 0.4 ETH (400 points)
- [ ] Total: 500 points (meets proposal threshold)
- [ ] Delegate to self on DAOToken
- [ ] Verify voting power with `getVotes()`

### Additional Users (For Quorum)
Need 40,000 votes total for quorum. Options:

**Option A: Multiple Test Accounts**
- [ ] Create 80 test accounts
- [ ] Each funds treasury with 0.5 ETH (500 points)
- [ ] Each delegates to self
- [ ] Total: 40,000 votes

**Option B: Lower Quorum for Testing**
- [ ] Deploy new Governor with lower quorum (e.g., 1,000)
- [ ] Update documentation with new address

**Option C: Community Testing**
- [ ] Share DAO with community
- [ ] Have others earn voting power
- [ ] Coordinate voting for test proposal

## Phase 2: Add DAO to Tally

- [ ] Visit [Tally.xyz](https://www.tally.xyz/)
- [ ] Click "Add a DAO"
- [ ] Enter Governor address: `0x97fE800648c002F456718F7F332cC394AdD96f61`
- [ ] Select network: Sepolia
- [ ] Wait for Tally to index the DAO
- [ ] Verify DAO appears on Tally
- [ ] Check that token is recognized
- [ ] Verify governance parameters display correctly

## Phase 3: Configure DAO Profile

- [ ] Set DAO name: "Participation DAO"
- [ ] Add description
- [ ] Upload logo (optional)
- [ ] Add website link (optional)
- [ ] Add social links (optional)
- [ ] Save profile

## Phase 4: Create Test Proposal

### Proposal 1: Release ETH from Treasury

- [ ] Ensure you have 500+ tokens
- [ ] Ensure voting power is delegated
- [ ] Wait 1 block after delegation
- [ ] Go to DAO on Tally
- [ ] Click "Create Proposal"
- [ ] Fill in details:
  - Title: "Test Proposal: Release 0.1 ETH"
  - Description: "Testing governance workflow"
- [ ] Add action:
  - Target: `0x896FAdfc6aD2f7856176CBD92474629C3320C909`
  - Function: `releaseETH`
  - Recipient: [your test address]
  - Amount: `100000000000000000` (0.1 ETH)
- [ ] Submit proposal
- [ ] Record proposal ID
- [ ] Record transaction hash

## Phase 5: Vote on Proposal

- [ ] Wait for voting delay (1 block)
- [ ] Go to proposal on Tally
- [ ] Cast vote: FOR
- [ ] Add voting reason (optional)
- [ ] Confirm transaction
- [ ] Record vote transaction hash
- [ ] Have other users vote (if using multiple accounts)
- [ ] Monitor vote count

## Phase 6: Queue Proposal

- [ ] Wait for voting period to end (259,200 blocks)
- [ ] Verify proposal passed
- [ ] Verify quorum was met
- [ ] Click "Queue" on Tally
- [ ] Confirm transaction
- [ ] Record queue transaction hash
- [ ] Note timelock end time

## Phase 7: Execute Proposal

- [ ] Wait for timelock delay (2 days)
- [ ] Click "Execute" on Tally
- [ ] Confirm transaction
- [ ] Record execution transaction hash
- [ ] Verify execution succeeded

## Phase 8: Verify Results

### Check Treasury
- [ ] Go to Treasury on Etherscan
- [ ] Verify ETH balance decreased by 0.1 ETH
- [ ] Check transaction history
- [ ] Verify `ETHReleased` event was emitted

### Check Recipient
- [ ] Go to recipient address on Etherscan
- [ ] Verify balance increased by 0.1 ETH
- [ ] Confirm transaction appears in history

### Check Proposal State
- [ ] Go to proposal on Tally
- [ ] Verify state shows "Executed"
- [ ] Check all votes are recorded
- [ ] Verify timeline is complete

## Phase 9: Document Results

### Update README.md
- [ ] Add Tally DAO URL
- [ ] Add proposal URL
- [ ] Add execution transaction hash
- [ ] Mark Tally integration as complete

### Create Results Document
- [ ] Proposal title and description
- [ ] Proposal ID
- [ ] Vote results (For/Against/Abstain)
- [ ] Quorum status
- [ ] All transaction hashes:
  - [ ] Proposal creation
  - [ ] Vote transactions
  - [ ] Queue transaction
  - [ ] Execute transaction
- [ ] Before/after state:
  - [ ] Treasury balance before
  - [ ] Treasury balance after
  - [ ] Recipient balance before
  - [ ] Recipient balance after
- [ ] Screenshots (optional):
  - [ ] Tally DAO page
  - [ ] Proposal page
  - [ ] Execution confirmation

## Phase 10: Optional Additional Tests

### Test Proposal 2: Update Parameter
- [ ] Create proposal to update `managedParameter`
- [ ] Target: Treasury
- [ ] Function: `setManagedParameter`
- [ ] New value: 200
- [ ] Follow voting workflow
- [ ] Verify parameter updated

### Test Proposal 3: Failed Proposal
- [ ] Create proposal
- [ ] Vote AGAINST
- [ ] Verify proposal fails
- [ ] Confirm it cannot be queued

### Test Delegation
- [ ] User A delegates to User B
- [ ] Verify User B's voting power increases
- [ ] User B votes with delegated power
- [ ] Verify vote counts correctly

## Troubleshooting Checklist

If something goes wrong:

- [ ] Check all contracts are verified on Etherscan
- [ ] Verify you have sufficient voting power
- [ ] Confirm delegation is active
- [ ] Check that voting delay has passed
- [ ] Verify voting period has ended (for queuing)
- [ ] Confirm timelock delay has passed (for execution)
- [ ] Check Treasury has sufficient balance
- [ ] Verify Timelock has accepted Treasury ownership
- [ ] Review transaction revert reasons on Etherscan
- [ ] Check Tally indexing status

## Success Criteria

✅ All items checked = Tally integration complete!

- [ ] DAO visible on Tally
- [ ] Proposal created successfully
- [ ] Votes cast and counted
- [ ] Quorum reached
- [ ] Proposal queued
- [ ] Timelock delay passed
- [ ] Proposal executed
- [ ] State changes verified
- [ ] All transactions documented
- [ ] README updated

## Resources

- **Tally Guide:** [TALLY_INTEGRATION.md](TALLY_INTEGRATION.md)
- **Quick Start:** [QUICKSTART.md](QUICKSTART.md)
- **Deployment Info:** [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)
- **Sepolia Etherscan:** https://sepolia.etherscan.io/
- **Tally Docs:** https://docs.tally.xyz/

---

**Start Date:** ___________  
**Completion Date:** ___________  
**Tally DAO URL:** ___________  
**Test Proposal URL:** ___________
