// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./VotingContract.sol";

contract VotingContractFactory {
    function createVotingContract(address _votingOpener, address _voter) public returns(address) {
        VotingContract newVotingContract = new VotingContract(_votingOpener, _voter);

        return address(newVotingContract);
    }
}