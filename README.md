# Participation-Based DAO

A decentralized autonomous organization where voting power is earned through active participation rather than token holdings. Built with Solidity and Foundry, this DAO rewards users for on-chain actions and enables democratic governance through OpenZeppelin's Governor framework.

## Overview

This project implements a participation-based governance system where users earn voting power by:
- **Funding the DAO treasury** with ETH (1 ETH = 1000 voting points)
- **Claiming periodic epoch-based check-ins** (100 points per epoch)

The system uses a non-transferable ERC20Votes token to track voting power, ensuring that influence is earned through contribution rather than purchased. All governance actions are executed through a timelock-controlled treasury, providing security and transparency for the DAO.

## Architecture

### Core Contracts

#### 1. DAOToken (`src/DaoToken.sol`)
A non-transferable ERC20Votes token that tracks voting power with checkpoint functionality.

**Key Features:**
- ERC20Votes compatible for Tally integration
- Non-transferable (can only mint/burn, not transfer between addresses)
- Delegation support via `delegate()` and `delegateBySig()` for gasless delegation
- ERC20Permit for gasless approvals
- Ownable with minter management system

**Token Details:**
- Name: DAO Token
- Symbol: DTK
- Decimals: 18 (standard ERC20)
- Solidity Version: 0.8.24

**Access Control:**
- Owner can add/remove minters
- Only approved minters can mint tokens
- Anyone can burn their own tokens

#### 2. VotingPowerEarner (`src/VotingPowerEarner.sol`)
Manages the earning of voting power through on-chain participation.

**Earning Mechanisms:**

1. **Epoch Check-In**
   - Claim once per epoch
   - Awards: 100 points
   - Function: `claimCheckIn()`
   - Requirement: Must not have claimed in current epoch

2. **Treasury Funding**
   - Send ETH to fund the DAO treasury
   - Conversion Rate: 1 ETH = 1000 points
   - Function: `fundTreasury()` (payable)
   - ETH is forwarded directly to treasury

**Caps & Limits:**
- Per-user cap per epoch: 500 points
- Global cap per epoch: 100,000 points
- Epoch duration: Configurable at deployment (default: 1 week)

**View Functions:**
- `currentEpoch()` - Returns the current epoch number
- `claimedCheckIn(address user)` - Check if user claimed check-in this epoch
- `remainingUserCap(address user)` - Points user can still earn this epoch
- `remainingGlobalCap()` - Points remaining in global epoch cap

**Security Features:**
- Pausable functionality for emergency stops
- AccessControl with ADMIN_ROLE for admin operations
- Checks-effects-interactions pattern on ETH transfers
- Per-epoch and per-user tracking to prevent gaming

**Events:**
- `PointsEarned(address indexed user, uint256 points, string action)` - Emitted when points are earned

#### 3. Treasury (`src/Treasury.sol`)
Holds DAO funds and executes approved governance proposals.

**Features:**
- Ownable2Step for secure ownership transfers
- ReentrancyGuard protection on all value transfers
- Receives ETH via `receive()` function
- Manages a configurable parameter for demonstration

**Functions:**
- `releaseETH(address payable recipient, uint256 amount)` - Release ETH to recipient (owner only)
- `setManagedParameter(uint256 newValue)` - Update managed parameter (owner only)
- `getBalance()` - View current ETH balance
- `getManagedParameter()` - View current parameter value

**Events:**
- `ETHReleased(address indexed recipient, uint256 amount)`
- `ParameterUpdated(string indexed paramName, uint256 oldValue, uint256 newValue)`

**Security:**
- Only owner (Timelock) can execute functions
- Validates recipient addresses and amounts
- Checks sufficient balance before transfers
- Reentrancy protection on all external calls

#### 4. DAOGovernor (`src/DAOGovernor.sol`)
OpenZeppelin Governor implementation with timelock control.

**Governance Parameters:**
- **Voting Delay**: 1 block (~12 seconds on Ethereum)
  - Allows time for users to delegate before voting starts
- **Voting Period**: 259,200 blocks (~36 days on Ethereum, ~3 days on faster chains)
  - Provides sufficient time for community participation
- **Proposal Threshold**: 500 tokens
  - Prevents spam while keeping proposals accessible
- **Quorum**: 40,000 votes
  - Ensures meaningful community participation (40% of max epoch cap)

**Extensions:**
- GovernorSettings - Configurable governance parameters
- GovernorCountingSimple - Simple For/Against/Abstain voting
- GovernorVotes - Reads voting power from ERC20Votes token
- GovernorTimelockControl - Integrates with TimelockController

**Governance Flow:**
1. **Propose** - Users with ≥500 tokens create proposals
2. **Vote** - Token holders vote during the voting period
3. **Queue** - Successful proposals are queued in timelock
4. **Execute** - After timelock delay, anyone can execute

#### 5. TimelockController (OpenZeppelin)
Provides a security delay between proposal approval and execution.

**Configuration:**
- **Minimum Delay**: 2 days (172,800 seconds)
  - Allows time to detect and respond to malicious proposals
- **Proposers**: DAOGovernor contract only
- **Executors**: Anyone (address(0)) after timelock delay
- **Admin**: Initially deployer, can be renounced after setup

## Project Structure

```
.
├── src/
│   ├── DaoToken.sol           # Non-transferable ERC20Votes token
│   ├── VotingPowerEarner.sol  # Participation tracking and point distribution
│   ├── Treasury.sol           # Treasury with timelock-controlled operations
│   └── DAOGovernor.sol        # OpenZeppelin Governor implementation
├── script/
│   └── Deploy.s.sol           # Deployment script for all contracts
├── test/
│   ├── DAOToken.t.sol         # Unit tests for token
│   ├── VotingPowerEarner.t.sol # Unit tests for earning mechanism
│   ├── Treasury.t.sol         # Unit tests for treasury
│   └── DAOIntegration.t.sol   # End-to-end integration tests
├── lib/                       # Dependencies (OpenZeppelin, Forge-std)
├── foundry.toml              # Foundry configuration
├── Makefile                  # Build and deployment commands
├── DEPLOYMENT.md             # Detailed deployment guide
└── README.md                 # This file
```

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- Sepolia testnet ETH (for deployment)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd <project-directory>

# Install dependencies
forge install
# or
make install
```

### Build

```bash
forge build
# or
make build
```

### Test

```bash
# Run all tests
forge test -vv
# or
make test

# Run specific test suites
make test-unit          # Unit tests only
make test-integration   # Integration tests only

# Run with gas reporting
make gas-report

# Run with coverage
make coverage
```

### Deploy

```bash
# Setup environment variables
cp .env.example .env
# Edit .env with your PRIVATE_KEY, SEPOLIA_RPC_URL, and ETHERSCAN_API_KEY

# Deploy to Sepolia testnet
make deploy-sepolia

# Or deploy without verification (faster)
make deploy-sepolia-fast
```

Deployment will create a `deployed-addresses.txt` file with all contract addresses.

## Usage

### Earning Voting Power

**Claim Check-In (100 points):**
```solidity
// Call once per epoch
VotingPowerEarner.claimCheckIn()
```

**Fund Treasury (1000 points per ETH):**
```solidity
// Send ETH to earn points
VotingPowerEarner.fundTreasury{value: 1 ether}()
```

### Delegation

**Delegate to yourself or another address:**
```solidity
DAOToken.delegate(address delegatee)
```

**Gasless delegation with EIP-712 signature:**
```solidity
DAOToken.delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
)
```

### Governance (via Tally)

Once deployed, governance actions are performed through [Tally](https://www.tally.xyz/):

1. **Connect wallet** with voting power (must have delegated to self or received delegation)
2. **Create proposal** with target contract, function, and parameters
3. **Vote** during the voting period (For/Against/Abstain)
4. **Queue** approved proposals (after voting period ends)
5. **Execute** after timelock delay (2 days)

### Example Proposal Actions

**Release ETH from Treasury:**
```solidity
Target: Treasury contract address
Function: releaseETH(address payable recipient, uint256 amount)
Parameters: [0x123..., 1000000000000000000] // recipient, 1 ETH in wei
```

**Update Treasury Parameter:**
```solidity
Target: Treasury contract address
Function: setManagedParameter(uint256 newValue)
Parameters: [200]
```

## Security Considerations

### Design Decisions

- **Non-transferable tokens** prevent vote buying and ensure voting power reflects actual participation
- **Epoch-based caps** prevent gaming the system through repeated actions
- **Pausable contracts** enable emergency response to discovered vulnerabilities
- **AccessControl** restricts sensitive operations to authorized addresses
- **Checks-effects-interactions** pattern prevents reentrancy attacks
- **No tx.origin** usage prevents phishing attacks
- **Timelock delay** provides 2-day window to detect and respond to malicious proposals
- **Ownable2Step** prevents accidental ownership transfers

### Governance Parameter Justification

- **Voting Delay (1 block)**: Minimal delay allows quick proposal start while preventing flash loan attacks
- **Voting Period (259,200 blocks)**: ~3 days on faster chains provides adequate participation time
- **Proposal Threshold (500 tokens)**: Accessible to active participants (1 epoch of max earning)
- **Quorum (40,000 votes)**: Requires 40% of single-epoch global cap, ensuring meaningful participation
- **Timelock Delay (2 days)**: Balance between security and execution speed

## Testing Strategy

### Unit Tests

Each contract has comprehensive unit tests covering:
- **DAOToken**: Minting, burning, delegation, non-transferability, access control
- **VotingPowerEarner**: Check-ins, treasury funding, caps, epochs, pausing
- **Treasury**: ETH releases, parameter updates, access control, reentrancy protection

### Integration Tests

Full end-to-end workflow testing:
- Users earn voting power through multiple mechanisms
- Delegation and vote counting
- Proposal creation, voting, queuing, and execution
- Quorum and threshold enforcement
- Real state changes in treasury
- Timelock delays and access control

### Running Tests

```bash
# All tests with verbose output
forge test -vv

# Specific test file
forge test --match-contract DAOTokenTest -vv

# Specific test function
forge test --match-test testFullWorkflow -vvv

# Gas reporting
forge test --gas-report

# Coverage report
forge coverage
```

## Development Roadmap

- [x] DAOToken implementation with ERC20Votes
- [x] VotingPowerEarner with dual earning mechanisms
- [x] Treasury with timelock control
- [x] DAOGovernor with OpenZeppelin extensions
- [x] TimelockController integration
- [x] Comprehensive unit tests
- [x] Integration tests for full workflow
- [x] Deployment script
- [x] Makefile for common operations
- [x] Testnet deployment
- [x] Tally integration and testing
- [x] Production deployment documentation

## Deployment Information

*To be updated after testnet deployment*

**Network:** Sepolia Testnet  
**Chain ID:** 11155111

**Contracts:**
- DAOToken: TBD
- VotingPowerEarner: TBD
- Treasury: TBD
- TimelockController: TBD
- DAOGovernor: TBD

**Tally Integration:**
- Governor URL: TBD
- Sample Proposal: TBD
- Execution Transaction: TBD

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Contributing

This is an educational project demonstrating participation-based DAO governance. Contributions, suggestions, and feedback are welcome.

## License

MIT

## Resources

- [OpenZeppelin Governor](https://docs.openzeppelin.com/contracts/4.x/governance)
- [Tally Documentation](https://docs.tally.xyz/)
- [Foundry Book](https://book.getfoundry.sh/)
- [ERC20Votes](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20#ERC20Votes)
