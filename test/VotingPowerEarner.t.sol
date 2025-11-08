// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VotingPowerEarner.sol";
import "../src/DAOToken.sol";
import "../src/Treasury.sol";

contract VotingPowerEarnerTest is Test {
    VotingPowerEarner public earner;
    DAOToken public token;
    Treasury public treasury;
    
    address public admin;
    address public user1;
    address public user2;
    
    uint256 constant EPOCH_DURATION = 1 weeks;

    function setUp() public {
        admin = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy contracts
        token = new DAOToken();
        treasury = new Treasury();
        earner = new VotingPowerEarner(
            address(token),
            EPOCH_DURATION,
            address(treasury)
        );
        
        // Setup permissions
        token.addMinter(address(earner));
        
        // Fund users for testing
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function testInitialState() public {
        assertEq(earner.currentEpoch(), 0);
        assertEq(earner.epochDuration(), EPOCH_DURATION);
        assertEq(earner.CHECK_IN_POINTS(), 100);
        assertEq(earner.USER_POINTS_CAP_PER_EPOCH(), 500);
        assertEq(earner.GLOBAL_POINTS_CAP_PER_EPOCH(), 100000);
    }

    function testCurrentEpoch() public {
        assertEq(earner.currentEpoch(), 0);
        
        // Move to next epoch
        vm.warp(block.timestamp + EPOCH_DURATION);
        assertEq(earner.currentEpoch(), 1);
        
        // Move to epoch 2
        vm.warp(block.timestamp + EPOCH_DURATION);
        assertEq(earner.currentEpoch(), 2);
    }

    function testClaimCheckIn() public {
        assertFalse(earner.claimedCheckIn(user1));
        
        vm.prank(user1);
        earner.claimCheckIn();
        
        assertTrue(earner.claimedCheckIn(user1));
        assertEq(token.balanceOf(user1), 100);
        assertEq(earner.remainingUserCap(user1), 400);
    }

    function testClaimCheckInTwiceInEpoch() public {
        vm.prank(user1);
        earner.claimCheckIn();
        
        vm.prank(user1);
        vm.expectRevert("VotingPowerEarner: Check-in already claimed for this epoch");
        earner.claimCheckIn();
    }

    function testClaimCheckInNewEpoch() public {
        vm.prank(user1);
        earner.claimCheckIn();
        
        // Move to next epoch
        vm.warp(block.timestamp + EPOCH_DURATION);
        
        vm.prank(user1);
        earner.claimCheckIn();
        
        assertEq(token.balanceOf(user1), 200); // 100 from each epoch
    }

    function testFundTreasury() public {
        uint256 ethAmount = 1 ether;
        uint256 expectedPoints = (ethAmount * 1000) / 1e18; // 1000 points
        
        vm.prank(user1);
        earner.fundTreasury{value: ethAmount}();
        
        assertEq(token.balanceOf(user1), expectedPoints);
        assertEq(address(treasury).balance, ethAmount);
        assertEq(earner.remainingUserCap(user1), 500 - expectedPoints);
    }

    function testFundTreasuryZeroValue() public {
        vm.prank(user1);
        vm.expectRevert("VotingPowerEarner: Must send ETH");
        earner.fundTreasury{value: 0}();
    }

    function testUserCapEnforcement() public {
        // Claim check-in (100 points)
        vm.prank(user1);
        earner.claimCheckIn();
        
        // Try to fund treasury with amount that would exceed cap
        uint256 ethAmount = 0.5 ether; // Would give 500 points, total 600 > 500 cap
        
        vm.prank(user1);
        vm.expectRevert("VotingPowerEarner: Exceeds epoch cap");
        earner.fundTreasury{value: ethAmount}();
    }

    function testGlobalCapEnforcement() public {
        // This test would require many users to hit the global cap
        // For simplicity, we'll test the view function
        assertEq(earner.remainingGlobalCap(), 100000);
        
        vm.prank(user1);
        earner.claimCheckIn();
        
        assertEq(earner.remainingGlobalCap(), 99900);
    }

    function testPauseUnpause() public {
        earner.pause();
        
        vm.prank(user1);
        vm.expectRevert("Pausable: paused");
        earner.claimCheckIn();
        
        earner.unpause();
        
        vm.prank(user1);
        earner.claimCheckIn(); // Should work now
        assertEq(token.balanceOf(user1), 100);
    }

    function testViewFunctions() public {
        assertEq(earner.remainingUserCap(user1), 500);
        assertEq(earner.remainingGlobalCap(), 100000);
        assertFalse(earner.claimedCheckIn(user1));
        
        vm.prank(user1);
        earner.claimCheckIn();
        
        assertEq(earner.remainingUserCap(user1), 400);
        assertEq(earner.remainingGlobalCap(), 99900);
        assertTrue(earner.claimedCheckIn(user1));
    }

    function testEvents() public {
        vm.expectEmit(true, false, false, true);
        emit VotingPowerEarner.PointsEarned(user1, 100, "Epoch Check-In");
        
        vm.prank(user1);
        earner.claimCheckIn();
        
        vm.expectEmit(true, false, false, true);
        emit VotingPowerEarner.PointsEarned(user1, 1000, "Treasury Funding");
        
        vm.prank(user1);
        earner.fundTreasury{value: 1 ether}();
    }
}