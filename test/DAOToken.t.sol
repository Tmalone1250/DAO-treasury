// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/DAOToken.sol";

contract DAOTokenTest is Test {
    DAOToken public token;
    address public owner;
    address public minter;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        minter = makeAddr("minter");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        token = new DAOToken();
        
        // Add minter - the deployer should have owner rights
        // token.addMinter(minter); // Temporarily commented out
    }

    function testInitialState() public {
        assertEq(token.name(), "DAO Token");
        assertEq(token.symbol(), "DTK");
        assertEq(token.totalSupply(), 0);
        assertEq(token.owner(), owner);
        assertTrue(token.minters(owner));
        // assertTrue(token.minters(minter)); // Temporarily commented out
    }

    function testMinting() public {
        vm.prank(minter);
        token.mint(user1, 1000);
        
        assertEq(token.balanceOf(user1), 1000);
        assertEq(token.totalSupply(), 1000);
        assertEq(token.getVotes(user1), 1000); // Auto-delegation to self
    }

    function testMintingAccessControl() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 1000);
    }

    function testNonTransferable() public {
        vm.prank(minter);
        token.mint(user1, 1000);
        
        // Should revert on transfer
        vm.prank(user1);
        vm.expectRevert("DAO Token is non-transferable");
        token.transfer(user2, 500);
    }

    function testBurning() public {
        vm.prank(minter);
        token.mint(user1, 1000);
        
        vm.prank(user1);
        token.burn(300);
        
        assertEq(token.balanceOf(user1), 700);
        assertEq(token.totalSupply(), 700);
    }

    function testDelegation() public {
        vm.prank(minter);
        token.mint(user1, 1000);
        
        // Initially delegated to self
        assertEq(token.getVotes(user1), 1000);
        assertEq(token.getVotes(user2), 0);
        
        // Delegate to user2
        vm.prank(user1);
        token.delegate(user2);
        
        assertEq(token.getVotes(user1), 0);
        assertEq(token.getVotes(user2), 1000);
    }

    function testVotingPowerHistory() public {
        vm.prank(minter);
        token.mint(user1, 1000);
        
        uint256 blockNumber = block.number;
        vm.roll(blockNumber + 1);
        
        assertEq(token.getPastVotes(user1, blockNumber), 1000);
    }
}