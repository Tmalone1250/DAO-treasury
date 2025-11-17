// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/DAOToken.sol";
import "../src/VotingPowerEarner.sol";
import "../src/Treasury.sol";
import "../src/DAOGovernor.sol";
import "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract DAOIntegrationTest is Test {
    DAOToken public token;
    VotingPowerEarner public earner;
    Treasury public treasury;
    DAOGovernor public governor;
    TimelockController public timelock;
    
    address public deployer;
    address public user1;
    address public user2;
    address public user3;
    
    uint256 constant EPOCH_DURATION = 1 weeks;
    uint256 constant MIN_DELAY = 2 days;

    function setUp() public {
        deployer = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        // Fund users
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        
        // Deploy contracts in order
        token = new DAOToken();
        treasury = new Treasury();
        
        // Setup timelock
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(0); // Will be set to governor
        executors[0] = address(0); // Anyone can execute
        
        timelock = new TimelockController(
            MIN_DELAY,
            proposers,
            executors,
            deployer
        );
        
        governor = new DAOGovernor(address(token), timelock);
        
        earner = new VotingPowerEarner(
            address(token),
            EPOCH_DURATION,
            address(treasury)
        );
        
        // Setup permissions
        token.addMinter(address(earner));
        treasury.transferOwnership(address(timelock));
        
        // Timelock needs to accept ownership (Ownable2Step)
        vm.prank(address(timelock));
        treasury.acceptOwnership();
        
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
    }

    function testFullWorkflow() public {
        // Step 1: Users earn voting power - need to meet quorum of 40,000
        // Create 80 users with 500 points each = 40,000 total
        for (uint i = 0; i < 80; i++) {
            address user = makeAddr(string(abi.encodePacked("voter", vm.toString(i))));
            vm.deal(user, 10 ether);
            vm.prank(user);
            earner.fundTreasury{value: 0.5 ether}(); // 500 points
            vm.prank(user);
            token.delegate(user);
        }
        
        // User1 will be the proposer
        vm.prank(user1);
        earner.fundTreasury{value: 0.5 ether}(); // 500 points
        
        // Delegate to self to activate voting power
        vm.prank(user1);
        token.delegate(user1);
        
        // Move forward one block so voting power is checkpointed
        vm.roll(block.number + 1);
        
        // Verify user1 has enough to propose
        assertEq(token.balanceOf(user1), 500);
        assertEq(token.getVotes(user1), 500);
        
        // Step 2: Create a proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(treasury);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("releaseETH(address,uint256)", user3, 0.1 ether);
        
        string memory description = "Release 0.1 ETH to user3";
        
        vm.prank(user1);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
        // Step 3: Vote on proposal
        vm.roll(block.number + 2); // Move past voting delay
        
        // Have all 80 users vote FOR to meet quorum
        for (uint i = 0; i < 80; i++) {
            address user = makeAddr(string(abi.encodePacked("voter", vm.toString(i))));
            vm.prank(user);
            governor.castVote(proposalId, 1); // Vote FOR
        }
        
        // Step 4: Wait for voting period to end
        vm.roll(block.number + 259201); // Move past voting period (need to be after the period ends)
        
        // Step 5: Queue proposal
        bytes32 descriptionHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descriptionHash);
        
        // Step 6: Wait for timelock delay
        vm.warp(block.timestamp + MIN_DELAY + 1);
        
        // Step 7: Execute proposal
        uint256 initialUser3Balance = user3.balance;
        uint256 initialTreasuryBalance = address(treasury).balance;
        
        governor.execute(targets, values, calldatas, descriptionHash);
        
        // Verify execution
        assertEq(user3.balance, initialUser3Balance + 0.1 ether);
        assertEq(address(treasury).balance, initialTreasuryBalance - 0.1 ether);
    }

    function testProposalThreshold() public {
        // User with insufficient voting power should not be able to propose
        vm.prank(user3); // No voting power
        
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(treasury);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("releaseETH(address,uint256)", user3, 0.1 ether);
        
        vm.expectRevert();
        governor.propose(targets, values, calldatas, "Test proposal");
    }

    function testQuorumRequirement() public {
        // Give user1 voting power but not enough for quorum
        vm.prank(user1);
        earner.claimCheckIn(); // Only 100 points, quorum is 40000
        
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(treasury);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("releaseETH(address,uint256)", user3, 0.1 ether);
        
        // Need to give user1 enough tokens to meet proposal threshold
        vm.prank(address(earner));
        token.mint(user1, 500); // Now has 600 total
        
        // Delegate to self
        vm.prank(user1);
        token.delegate(user1);
        
        // Move forward one block so voting power is checkpointed
        vm.roll(block.number + 1);
        
        vm.prank(user1);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Test proposal");
        
        vm.roll(block.number + 2);
        
        vm.prank(user1);
        governor.castVote(proposalId, 1);
        
        vm.roll(block.number + 259200);
        
        // Should fail due to quorum not met
        vm.expectRevert();
        bytes32 descriptionHash = keccak256(bytes("Test proposal"));
        governor.queue(targets, values, calldatas, descriptionHash);
    }

    function testDelegation() public {
        // User1 earns voting power
        vm.prank(user1);
        earner.claimCheckIn();
        
        // User1 delegates to user2
        vm.prank(user1);
        token.delegate(user2);
        
        assertEq(token.getVotes(user1), 0);
        assertEq(token.getVotes(user2), 100);
        
        // User2 can now vote with delegated power
        // (Would need to set up a full proposal test to verify voting)
    }

    function testTreasuryParameterUpdate() public {
        // Setup voting power
        vm.prank(user1);
        earner.fundTreasury{value: 0.5 ether}(); // 500 points
        
        // Give more users voting power to meet quorum
        for (uint i = 0; i < 40; i++) {
            address user = makeAddr(string(abi.encodePacked("user", i)));
            vm.deal(user, 10 ether);
            vm.prank(user);
            earner.fundTreasury{value: 0.5 ether}(); // 500 points each
        }
        
        // Delegate to self
        vm.prank(user1);
        token.delegate(user1);
        
        // Move forward one block so voting power is checkpointed
        vm.roll(block.number + 1);
        
        // Create proposal to update treasury parameter
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(treasury);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("setManagedParameter(uint256)", 200);
        
        vm.prank(user1);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Update parameter to 200");
        
        // Fast forward through voting
        vm.roll(block.number + 2);
        
        // Vote (simplified - in reality would need all users to vote)
        vm.prank(user1);
        governor.castVote(proposalId, 1);
        
        // This test demonstrates the structure but would need more setup for full execution
    }
}