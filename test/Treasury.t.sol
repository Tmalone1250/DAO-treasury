// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Treasury.sol";

contract TreasuryTest is Test {
    Treasury public treasury;
    address public owner;
    address public recipient;
    address public nonOwner;

    function setUp() public {
        owner = address(this);
        recipient = makeAddr("recipient");
        nonOwner = makeAddr("nonOwner");
        
        treasury = new Treasury();
        
        // Fund treasury
        vm.deal(address(treasury), 10 ether);
    }

    function testInitialState() public {
        assertEq(treasury.owner(), owner);
        assertEq(treasury.getBalance(), 10 ether);
        assertEq(treasury.getManagedParameter(), 100);
    }

    function testReceiveETH() public {
        uint256 initialBalance = treasury.getBalance();
        
        (bool success, ) = address(treasury).call{value: 1 ether}("");
        assertTrue(success);
        
        assertEq(treasury.getBalance(), initialBalance + 1 ether);
    }

    function testReleaseETH() public {
        uint256 amount = 2 ether;
        uint256 initialRecipientBalance = recipient.balance;
        
        treasury.releaseETH(payable(recipient), amount);
        
        assertEq(recipient.balance, initialRecipientBalance + amount);
        assertEq(treasury.getBalance(), 8 ether);
    }

    function testReleaseETHAccessControl() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        treasury.releaseETH(payable(recipient), 1 ether);
    }

    function testReleaseETHInvalidRecipient() public {
        vm.expectRevert("Treasury: Invalid recipient");
        treasury.releaseETH(payable(address(0)), 1 ether);
    }

    function testReleaseETHZeroAmount() public {
        vm.expectRevert("Treasury: Amount must be greater than 0");
        treasury.releaseETH(payable(recipient), 0);
    }

    function testReleaseETHInsufficientBalance() public {
        vm.expectRevert("Treasury: Insufficient balance");
        treasury.releaseETH(payable(recipient), 20 ether);
    }

    function testSetManagedParameter() public {
        uint256 newValue = 200;
        
        treasury.setManagedParameter(newValue);
        
        assertEq(treasury.getManagedParameter(), newValue);
    }

    function testSetManagedParameterAccessControl() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        treasury.setManagedParameter(200);
    }

    function testSetManagedParameterZeroValue() public {
        vm.expectRevert("Treasury: Parameter must be greater than 0");
        treasury.setManagedParameter(0);
    }

    function testEvents() public {
        vm.expectEmit(true, false, false, true);
        emit Treasury.ETHReleased(recipient, 1 ether);
        treasury.releaseETH(payable(recipient), 1 ether);
        
        vm.expectEmit(true, false, false, true);
        emit Treasury.ParameterUpdated("managedParameter", 100, 200);
        treasury.setManagedParameter(200);
    }

    function testOwnershipTransfer() public {
        address newOwner = makeAddr("newOwner");
        
        treasury.transferOwnership(newOwner);
        
        vm.prank(newOwner);
        treasury.acceptOwnership();
        
        assertEq(treasury.owner(), newOwner);
    }
}