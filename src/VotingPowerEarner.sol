// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Context.sol";

// IDAOToken Interface
interface IDAOToken {
    function mint(address to, uint256 amount) external;
}

contract VotingPowerEarner is AccessControl, Pausable {
    // State Variabes
    uint256 public epochDuration;
    uint256 public immutable deploymentTimestamp;

    uint256 public constant CHECK_IN_POINTS = 100;
    uint256 public constant USER_POINTS_CAP_PER_EPOCH = 500;
    uint256 public constant GLOBAL_POINTS_CAP_PER_EPOCH = 100000;

    IDAOToken public immutable daoToken;

    address public immutable treasuryAddress;
    uint256 public constant ETH_TO_POINTS_RATE = 1000;

    // Mappings
    mapping(uint256 => uint256) public totalPointsEarnedInEpoch;
    mapping(address => mapping(uint256 => bool)) public hasClaimedCheckIn;
    mapping(address => mapping(uint256 => uint256))
        public userPointsEarnedInEpoch;

    // Roles
    bytes32 public constant ADMIN_ROLE = DEFAULT_ADMIN_ROLE;

    // Events
    event PointsEarned(address indexed user, uint256 points, string action);

    //Constructor
    constructor(
        address _daotoken,
        uint256 _epochDuration,
        address _treasuryAddress
    ) {
        daoToken = IDAOToken(_daotoken);
        epochDuration = _epochDuration;
        deploymentTimestamp = block.timestamp;

        treasuryAddress = _treasuryAddress;

        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // currentEpoch() function
    function currentEpoch() public view returns (uint256) {
        if (block.timestamp < deploymentTimestamp) return 0;
        return ((block.timestamp - deploymentTimestamp) / epochDuration);
    }

    // claimedCheckIn() function
    function claimedCheckIn(address user) public view returns (bool) {
        return hasClaimedCheckIn[user][currentEpoch()];
    }

    // remainingUserCap() function
    function remainingUserCap(address user) public view returns (uint256) {
        uint256 earned = userPointsEarnedInEpoch[user][currentEpoch()];
        if (earned >= USER_POINTS_CAP_PER_EPOCH) {
            return 0;
        }
        return USER_POINTS_CAP_PER_EPOCH - earned;
    }

    // remainingGlobalCap() function
    function remainingGlobalCap() public view returns (uint256) {
        uint256 earned = totalPointsEarnedInEpoch[currentEpoch()];
        if (earned >= GLOBAL_POINTS_CAP_PER_EPOCH) {
            return 0;
        }

        return GLOBAL_POINTS_CAP_PER_EPOCH - earned;
    }

    // claimCheckIn() function
    function claimCheckIn() public whenNotPaused {
        address user = msg.sender;
        uint256 current = currentEpoch();
        uint256 pointsToAward = CHECK_IN_POINTS;

        require(
            !hasClaimedCheckIn[user][current],
            "VotingPowerEarner: Check-in already claimed for this epoch"
        );

        uint256 currentEarned = userPointsEarnedInEpoch[user][current];
        require(
            currentEarned + pointsToAward <= USER_POINTS_CAP_PER_EPOCH,
            "VotingPowerEarner: Exceeds current epoch cap"
        );

        uint256 globalEarned = totalPointsEarnedInEpoch[current];
        require(
            globalEarned + pointsToAward <= GLOBAL_POINTS_CAP_PER_EPOCH,
            "VotingPowerEarner: Exceeds global epoch cap"
        );

        hasClaimedCheckIn[user][current] = true;
        userPointsEarnedInEpoch[user][current] = currentEarned + pointsToAward;
        totalPointsEarnedInEpoch[current] = globalEarned + pointsToAward;

        daoToken.mint(user, pointsToAward);

        emit PointsEarned(user, pointsToAward, "Epoch Check-In");
    }

    // fundTreasury() function
    function fundTreasury() public payable whenNotPaused {
        address user = msg.sender;
        uint256 current = currentEpoch();
        require(msg.value > 0, "VotingPowerEarner: Must send ETH");

        uint256 pointsToAward = (msg.value * ETH_TO_POINTS_RATE) / 1e18;
        require(
            pointsToAward > 0,
            "VotingPowerEarner: ETH amount too low to earn points"
        );

        uint256 currentEarned = userPointsEarnedInEpoch[user][current];
        require(
            currentEarned + pointsToAward <= USER_POINTS_CAP_PER_EPOCH,
            "VotingPowerEarner: Exceeds epoch cap"
        );

        uint256 globalEarned = totalPointsEarnedInEpoch[current];
        require(
            globalEarned + pointsToAward <= GLOBAL_POINTS_CAP_PER_EPOCH,
            "VotingPowerEarner: Exceeds global epoch cap"
        );

        userPointsEarnedInEpoch[user][current] = currentEarned + pointsToAward;
        totalPointsEarnedInEpoch[current] = globalEarned + pointsToAward;

        daoToken.mint(user, pointsToAward);

        (bool success, ) = payable(treasuryAddress).call{value: msg.value}("");
        require(success, "VoterPowerEarner: ETH transfer treasury failed");

        emit PointsEarned(user, pointsToAward, "Treasury Funding");
    }

    // Admin functions
    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
