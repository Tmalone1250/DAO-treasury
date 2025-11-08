// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Treasury is Ownable2Step, ReentrancyGuard {
    
    event ETHReleased(address indexed recipient, uint256 amount);
    event ParameterUpdated(string indexed paramName, uint256 oldValue, uint256 newValue);
    
    // Example managed parameter
    uint256 public managedParameter = 100;
    
    constructor() Ownable(msg.sender) {}
    
    // Receive ETH
    receive() external payable {}
    
    // Release ETH to a recipient (only owner - which will be the timelock)
    function releaseETH(address payable recipient, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        require(recipient != address(0), "Treasury: Invalid recipient");
        require(amount > 0, "Treasury: Amount must be greater than 0");
        require(address(this).balance >= amount, "Treasury: Insufficient balance");
        
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Treasury: ETH transfer failed");
        
        emit ETHReleased(recipient, amount);
    }
    
    // Update managed parameter (only owner - which will be the timelock)
    function setManagedParameter(uint256 newValue) external onlyOwner {
        require(newValue > 0, "Treasury: Parameter must be greater than 0");
        
        uint256 oldValue = managedParameter;
        managedParameter = newValue;
        
        emit ParameterUpdated("managedParameter", oldValue, newValue);
    }
    
    // View functions
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getManagedParameter() external view returns (uint256) {
        return managedParameter;
    }
}