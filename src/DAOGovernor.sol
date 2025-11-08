// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "lib/openzeppelin-contracts/contracts/governance/Governor.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC5805.sol";

contract DAOGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorTimelockControl {

    // State Variables
    uint256 public constant QUORUM_VOTES = 40000;

    // Constructor
    constructor(
        address _token, 
        TimelockController _timelock
    ) 
        Governor("ParticipationDAO Governor") 
        GovernorSettings(1, 259200, 500) // 1 block delay, ~3 days voting, 500 token threshold
        GovernorVotes(IVotes(_token))
        GovernorTimelockControl(_timelock)
    {}

    // Required overrides
    function quorum(uint256 /* blockNumber */) public pure override returns (uint256) {
        return QUORUM_VOTES;
    }

    function proposalThreshold() 
        public 
        view 
        override(Governor, GovernorSettings) 
        returns (uint256) 
    {
        return super.proposalThreshold();
    }

    function state(uint256 proposalId) 
        public 
        view 
        override(Governor, GovernorTimelockControl) 
        returns (ProposalState) 
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}