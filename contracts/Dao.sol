// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DAO {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
        mapping(address => bool) voted;
    }

    address public owner;
    bool public isCreated = false; // DAO daha önce oluşturuldu mu?
    uint256 public proposalCount;
    uint256 public votingDuration = 3 days; // 3 gün oylama süresi

    mapping(address => uint256) public tokenBalance;
    mapping(uint256 => Proposal) public proposals;

    event DAOCreated(
        string name,
        string purpose,
        string tokenDetails,
        string votingMechanism
    );
    event ProposalCreated(
        uint256 indexed proposalId,
        string description,
        uint256 deadline
    );
    event Voted(uint256 indexed proposalId, address voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId, bool passed);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier daoExists() {
        require(isCreated, "DAO has not been created yet!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createDAO(
        string memory _name,
        string memory _purpose,
        string memory _tokenDetails,
        string memory _votingMechanism
    ) public onlyOwner {
        require(!isCreated, "DAO has already been created!");
        isCreated = true;

        // İlk sahibi token ile ödüllendir
        tokenBalance[msg.sender] = 1000;

        emit DAOCreated(_name, _purpose, _tokenDetails, _votingMechanism);
    }

    function createProposal(string memory _description) public daoExists {
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + votingDuration;

        emit ProposalCreated(proposalCount, _description, newProposal.deadline);
        proposalCount++;
    }

    function vote(uint256 _proposalId, bool support) public daoExists {
        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!proposal.voted[msg.sender], "You have already voted");

        proposal.voted[msg.sender] = true;

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, support);
    }

    function executeProposal(uint256 _proposalId) public onlyOwner daoExists {
        Proposal storage proposal = proposals[_proposalId];

        require(
            block.timestamp >= proposal.deadline,
            "Voting period not yet ended"
        );
        require(!proposal.executed, "Proposal already executed");

        bool passed = proposal.votesFor > proposal.votesAgainst;
        proposal.executed = true;

        emit ProposalExecuted(_proposalId, passed);
    }

    // ✅ Frontend'in doğrudan struct'a erişebilmesi için getProposal() fonksiyonu ekledik.
    function getProposal(
        uint256 _proposalId
    ) public view returns (string memory, uint256, uint256, uint256, bool) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.deadline,
            proposal.executed
        );
    }
}
