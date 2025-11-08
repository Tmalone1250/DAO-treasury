// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/DAOToken.sol";
import "../src/VotingPowerEarner.sol";
import "../src/Treasury.sol";
import "../src/DAOGovernor.sol";
import "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract DeployScript is Script {
    
    // Deployment parameters
    uint256 constant EPOCH_DURATION = 1 weeks; // 7 days per epoch
    uint256 constant MIN_DELAY = 2 days; // Timelock delay
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts with deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy DAO Token
        console.log("Deploying DAO Token...");
        DAOToken daoToken = new DAOToken();
        console.log("DAO Token deployed at:", address(daoToken));
        
        // 2. Deploy Treasury
        console.log("Deploying Treasury...");
        Treasury treasury = new Treasury();
        console.log("Treasury deployed at:", address(treasury));
        
        // 3. Deploy TimelockController
        console.log("Deploying TimelockController...");
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        
        // Governor will be the proposer (set after deployment)
        proposers[0] = address(0); // Will be updated after governor deployment
        executors[0] = address(0); // Anyone can execute after timelock
        
        TimelockController timelock = new TimelockController(
            MIN_DELAY,
            proposers,
            executors,
            deployer // Admin (will renounce after setup)
        );
        console.log("TimelockController deployed at:", address(timelock));
        
        // 4. Deploy Governor
        console.log("Deploying DAO Governor...");
        DAOGovernor governor = new DAOGovernor(
            address(daoToken),
            timelock
        );
        console.log("DAO Governor deployed at:", address(governor));
        
        // 5. Deploy VotingPowerEarner
        console.log("Deploying VotingPowerEarner...");
        VotingPowerEarner earner = new VotingPowerEarner(
            address(daoToken),
            EPOCH_DURATION,
            address(treasury)
        );
        console.log("VotingPowerEarner deployed at:", address(earner));
        
        // 6. Setup permissions
        console.log("Setting up permissions...");
        
        // Add VotingPowerEarner as minter
        daoToken.addMinter(address(earner));
        
        // Transfer Treasury ownership to Timelock
        treasury.transferOwnership(address(timelock));
        
        // Grant proposer role to Governor in Timelock
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        
        // Revoke admin role from deployer (optional - comment out for testing)
        // timelock.revokeRole(timelock.TIMELOCK_ADMIN_ROLE(), deployer);
        
        vm.stopBroadcast();
        
        // Log deployment summary
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Network: Sepolia Testnet");
        console.log("Deployer:", deployer);
        console.log("DAO Token:", address(daoToken));
        console.log("Treasury:", address(treasury));
        console.log("TimelockController:", address(timelock));
        console.log("DAO Governor:", address(governor));
        console.log("VotingPowerEarner:", address(earner));
        console.log("Epoch Duration:", EPOCH_DURATION, "seconds");
        console.log("Timelock Delay:", MIN_DELAY, "seconds");
        
        // Save addresses to file for Tally integration
        string memory addresses = string(abi.encodePacked(
            "DAO_TOKEN=", vm.toString(address(daoToken)), "\n",
            "TREASURY=", vm.toString(address(treasury)), "\n",
            "TIMELOCK=", vm.toString(address(timelock)), "\n",
            "GOVERNOR=", vm.toString(address(governor)), "\n",
            "EARNER=", vm.toString(address(earner)), "\n"
        ));
        
        vm.writeFile("deployed-addresses.txt", addresses);
        console.log("Addresses saved to deployed-addresses.txt");
    }
}