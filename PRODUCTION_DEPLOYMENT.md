# Production Deployment Documentation

## Deployment Information

**Network:** Sepolia Testnet  
**Chain ID:** 11155111  
**Deployment Date:** November 9, 2025  
**Deployer Address:** `0xd83B5031506039893BF1C827b0A79aDDee71E1fE`

## Deployed Contract Addresses

| Contract | Address | Etherscan Link |
|----------|---------|----------------|
| **DAOToken** | `0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00` | [View on Etherscan](https://sepolia.etherscan.io/address/0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00) |
| **Treasury** | `0x97fE800648c002F456718F7F332cC394AdD96f61` | [View on Etherscan](https://sepolia.etherscan.io/address/0x97fE800648c002F456718F7F332cC394AdD96f61) |
| **TimelockController** | `0x1E6b8e878E5d3E4a3869839941A591D9697cF246` | [View on Etherscan](https://sepolia.etherscan.io/address/0x1E6b8e878E5d3E4a3869839941A591D9697cF246) |
| **DAOGovernor** | `0x896FAdfc6aD2f7856176CBD92474629C3320C909` | [View on Etherscan](https://sepolia.etherscan.io/address/0x896FAdfc6aD2f7856176CBD92474629C3320C909) |
| **VotingPowerEarner** | `0x06bff26d2FE28B2fDd50E6Bf550407B97BD75D73` | [View on Etherscan](https://sepolia.etherscan.io/address/0x06bff26d2FE28B2fDd50E6Bf550407B97BD75D73) |

## Configuration Parameters

### Governance Settings
- **Voting Delay:** 1 block (~12 seconds)
- **Voting Period:** 259,200 blocks (~36 days on Ethereum, ~3 days on faster chains)
- **Proposal Threshold:** 500 tokens
- **Quorum:** 40,000 votes
- **Timelock Delay:** 172,800 seconds (2 days)

### Earning Parameters
- **Epoch Duration:** 604,800 seconds (1 week)
- **Check-in Points:** 100 per epoch
- **Treasury Funding Rate:** 1000 points per ETH
- **User Cap per Epoch:** 500 points
- **Global Cap per Epoch:** 100,000 points

## Deployment Steps Completed

1. ✅ **DAOToken Deployed**
   - Non-transferable ERC20Votes token
   - Minter role granted to VotingPowerEarner
   - Owner: Deployer (can add/remove minters)

2. ✅ **Treasury Deployed**
   - Ownable2Step for secure ownership transfer
   - Ownership transferred to TimelockController (pending acceptance)
   - ReentrancyGuard protection enabled

3. ✅ **TimelockController Deployed**
   - 2-day delay for security
   - Proposer role granted to DAOGovernor
   - Executor role open to anyone (address(0))
   - Admin role: Deployer (can be renounced)

4. ✅ **DAOGovernor Deployed**
   - Connected to DAOToken for voting power
   - Connected to TimelockController for execution
   - All governance parameters configured

5. ✅ **VotingPowerEarner Deployed**
   - Connected to DAOToken for minting
   - Connected to Treasury for ETH forwarding
   - Admin role: Deployer (can pause/unpause)

6. ✅ **Permissions Configured**
   - VotingPowerEarner added as minter on DAOToken
   - Treasury ownership transferred to Timelock
   - Governor granted proposer role on Timelock

## Post-Deployment Actions Required

### 1. Accept Treasury Ownership
The Treasury ownership transfer needs to be accepted by the Timelock. This will be done through a governance proposal.

**Action:** Create a proposal to call `treasury.acceptOwnership()` from the Timelock.

### 2. Tally Integration

#### Step 1: Add DAO to Tally
1. Visit [Tally.xyz](https://www.tally.xyz/)
2. Click "Add a DAO"
3. Enter Governor address: `0x97fE800648c002F456718F7F332cC394AdD96f61`
4. Select network: Sepolia
5. Complete the setup wizard

#### Step 2: Configure DAO Profile
- **Name:** Participation DAO
- **Description:** A DAO where voting power is earned through active participation
- **Website:** [Your website]
- **Logo:** [Your logo]

#### Step 3: Verify Integration
- Confirm token is recognized: `0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00`
- Verify governance parameters display correctly
- Test delegation functionality

### 3. Test Proposal Workflow

#### Earn Voting Power
Users can earn voting power through:

**Option 1: Claim Check-in**
```solidity
// Call on VotingPowerEarner contract
claimCheckIn()
// Awards: 100 points
// Frequency: Once per epoch (1 week)
```

**Option 2: Fund Treasury**
```solidity
// Send ETH to VotingPowerEarner contract
fundTreasury{value: 0.5 ether}()
// Awards: 500 points (1000 points per ETH)
// Limit: Up to 500 points per epoch per user
```

#### Delegate Voting Power
```solidity
// Call on DAOToken contract
delegate(address delegatee)
// Delegate to self or another address
```

#### Create Test Proposal on Tally
1. Ensure you have ≥500 tokens and have delegated
2. Create proposal with target action:
   - **Target:** Treasury (`0x896FAdfc6aD2f7856176CBD92474629C3320C909`)
   - **Function:** `releaseETH(address payable recipient, uint256 amount)`
   - **Parameters:** 
     - recipient: `[test address]`
     - amount: `100000000000000000` (0.1 ETH in wei)
3. Wait for voting delay (1 block)
4. Vote on proposal
5. Wait for voting period to end
6. Queue proposal (if passed)
7. Wait for timelock delay (2 days)
8. Execute proposal

## Security Considerations

### Access Control
- **DAOToken Owner:** Deployer (can add/remove minters)
- **Treasury Owner:** TimelockController (after acceptance)
- **Timelock Admin:** Deployer (should be renounced after testing)
- **Timelock Proposer:** DAOGovernor only
- **Timelock Executor:** Anyone (after delay)
- **VotingPowerEarner Admin:** Deployer (can pause/unpause)

### Recommended Actions
1. ✅ Test full proposal workflow on testnet
2. ⏳ Renounce timelock admin role after confirming everything works
3. ⏳ Consider multi-sig for VotingPowerEarner admin role
4. ⏳ Monitor for any unusual activity during testing phase

## Verification Status

All contracts should be verified on Etherscan. If verification failed during deployment, verify manually:

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

Example:
```bash
forge verify-contract 0x2cc82f88c20E77a896Ef82234E68E3DbA5189d00 src/DaoToken.sol:DAOToken \
  --chain sepolia \
  --etherscan-api-key G35VC3Z6X3TDRCW572SWSV2K6A6J3VSBDY
```

## Testing Checklist

- [ ] Verify all contracts on Etherscan
- [ ] Test earning voting power (check-in)
- [ ] Test earning voting power (treasury funding)
- [ ] Test delegation functionality
- [ ] Add DAO to Tally
- [ ] Create test proposal on Tally
- [ ] Vote on proposal
- [ ] Queue and execute proposal
- [ ] Verify state changes after execution
- [ ] Document results with transaction hashes

## Useful Links

- **Sepolia Etherscan:** https://sepolia.etherscan.io/
- **Tally:** https://www.tally.xyz/
- **Sepolia Faucet:** https://sepoliafaucet.com/
- **Alchemy Sepolia Faucet:** https://www.alchemy.com/faucets/ethereum-sepolia

## Support

For issues or questions:
1. Check contract verification on Etherscan
2. Review transaction logs for errors
3. Consult OpenZeppelin Governor documentation
4. Check Tally documentation for integration issues

## Next Steps

1. Complete Tally integration
2. Run end-to-end test proposal
3. Document test results
4. Update README.md with Tally URL and test results
5. Consider mainnet deployment (if applicable)

---

**Deployment Completed:** ✅  
**Tally Integration:** ⏳ Pending  
**Test Proposal:** ⏳ Pending  
**Production Ready:** ⏳ After testing
