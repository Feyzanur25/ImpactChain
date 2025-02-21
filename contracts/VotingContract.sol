// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract VotingContract {
    uint256 public votingIndex;
    address public votingOpener;
    address public voter;

    mapping(uint256 index => mapping(string => uint256)) public results;
    mapping(uint256 index => mapping(address => bool)) public isVoted;

    struct Voting {
        uint256 index;
        string votingName;
        string votingDescription;
        string[] choices;
        uint256 endDate;
    }

    event VotingCreated(
        uint256 indexed index,
        string votingName,
        string votingDescription,
        string[] choices,
        uint256 endDate
    );
    event Voted(uint256 indexed index, address indexed voter, string choice);

    Voting[] public votings;

    constructor(address _votingOpener, address _voter) {
        require(_votingOpener != address(0), "Invalid votingOpener address");
        require(_voter != address(0), "Invalid voter address");

        votingOpener = _votingOpener;
        voter = _voter;
    }

    function createNewVoting(
        string memory _votingName,
        string memory _votingDescription,
        string[] memory _choices
    ) public {
        require(msg.sender == votingOpener, "Caller is not the votingOpener");
        require(_choices.length > 0, "At least one choice is required");

        // Check for duplicate choices
        for (uint256 i = 0; i < _choices.length; i++) {
            for (uint256 j = i + 1; j < _choices.length; j++) {
                require(
                    keccak256(bytes(_choices[i])) !=
                        keccak256(bytes(_choices[j])),
                    "Choices must be unique"
                );
            }
        }

        IToken _token = IToken(votingOpener);
        require(_token.balanceOf(msg.sender) > 0, "Insufficient Balance");

        Voting memory newVoting = Voting({
            index: votingIndex,
            votingName: _votingName,
            votingDescription: _votingDescription,
            choices: _choices,
            endDate: block.timestamp + 3 days
        });

        votings.push(newVoting);
        votingIndex++;

        emit VotingCreated(
            newVoting.index,
            newVoting.votingName,
            newVoting.votingDescription,
            newVoting.choices,
            newVoting.endDate
        );
    }

    function vote(uint256 _index, string memory _choice) public {
        require(msg.sender == voter, "Caller is not the voter");
        require(_index < votings.length, "Invalid voting index");
        require(!isVoted[_index][msg.sender], "Already voted");
        require(block.timestamp <= votings[_index].endDate, "Voting has ended");

        // Check if the choice is valid
        bool isValidChoice = false;
        for (uint256 i = 0; i < votings[_index].choices.length; i++) {
            if (
                keccak256(bytes(votings[_index].choices[i])) ==
                keccak256(bytes(_choice))
            ) {
                isValidChoice = true;
                break;
            }
        }
        require(isValidChoice, "Invalid choice");

        IToken _token = IToken(voter);
        require(_token.balanceOf(msg.sender) > 0, "Insufficient Balance");

        results[_index][_choice] += 1;
        isVoted[_index][msg.sender] = true;

        emit Voted(_index, msg.sender, _choice);
    }

    function getVotings() public view returns (Voting[] memory) {
        return votings;
    }

    function getResult(
        uint256 _index
    ) public view returns (string[] memory, uint256[] memory) {
        require(_index < votings.length, "Invalid voting index");

        Voting storage voting = votings[_index];
        uint256[] memory voteCounts = new uint256[](voting.choices.length);
        string[] memory choices = voting.choices;

        for (uint256 i = 0; i < voting.choices.length; i++) {
            voteCounts[i] = results[_index][choices[i]];
        }

        return (choices, voteCounts);
    }
}
