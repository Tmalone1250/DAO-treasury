// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DAOToken is ERC20, ERC20Votes, ERC20Permit, Ownable {
    mapping(address => bool) public minters;

    constructor()
        ERC20("DAO Token", "DTK")
        ERC20Permit("DAO Token")
        Ownable(msg.sender)
    {
        minters[msg.sender] = true;
    }

    // Override to resolve the conflict (delegates to ERC20Permit's implementation)
    function nonces(
        address owner
    ) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Votes) {
        require(
            from == address(0) || to == address(0),
            "DAO Token is non-transferable"
        );

        super._update(from, to, value);
    }

    // Mint function with access control
    function mint(address to, uint256 amount) public {
        require(minters[msg.sender], "DAOToken: caller is not a minter");
        _mint(to, amount);
    }

    // Add minter (only owner)
    function addMinter(address minter) public onlyOwner {
        minters[minter] = true;
    }

    // Remove minter (only owner)
    function removeMinter(address minter) public onlyOwner {
        minters[minter] = false;
    }

    // Burn function
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
