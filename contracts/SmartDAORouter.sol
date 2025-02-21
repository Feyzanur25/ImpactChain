// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

struct DAO {
        uint256 index;
        string daoName;
        address votingContract;
        address votingOpener;
        address voter;
        address treasuryVotingContract;
        address treasuryVotingOpener;
        address treasuryVoter;
        string logoURL;
        string website;
}

struct Voting {
        uint256 index;
        string votingName;
        string votingDescription;
        string[] choices;
        uint256 endDate;
}

struct TreasuryVoting {
        uint256 index;
        string votingName;
        string votingDescription;
        address to;
        uint256 amount;
        address tokenContract;
        uint256 yes;
        uint256 no;
        uint256 endDate;
        bool isPaid;
}

interface IVotingContractFactory {
     function createVotingContract(address _votingOpener, address _voter) external returns(address);
}

interface ITreasuryContractFactory {
    function createTreasuryContract(address _votingOpener, address _voter) external returns(address);
}

interface IDefaultERC20Factory {
    function createDefaultERC20(string memory _name, string memory _symbol, uint256 _totalSupply, address _creator) external returns(address);
}

interface IDefaultERC721Factory{
    function createDefaultERC721(string memory _name, string memory _symbol, uint256 _totalSupply) external returns(address);
}

interface IStorage{
    function addNewDAO(DAO memory _newDAO) external;
    function getDAOs() external view returns(DAO[] memory);
}

interface IVotingContract {
    function createNewVoting(address _caller, string memory _votingName, string memory _votingDescription, string[] memory _choices) external;
    function vote(address _caller, uint256 _index, string memory _choice) external;
    function getVotings() external view returns(Voting[] memory);
    function getResult(uint256 _index) external view returns (string[] memory, uint256[] memory);
}

interface ITreasuryVotingContract {
    function createTreasuryVoting(string memory _votingName, string memory _votingDescription, address _to, uint256 _amount, address _tokenContract) external;
    function vote(address _caller, uint256 _index, bool _vote) external;
    function getVotings() external view returns(TreasuryVoting[] memory);
    function getResult(uint256 _index) external view returns (uint256 yesVotes, uint256 noVotes);
    function finishContract(uint256 _index) external;
}

contract SmartDAORouter {
    uint256 public daoIndex;
    address public VotingContractFactory;
    address public TreasuryContractFactory;
    address public DefaultERC20Factory;
    address public DefaultERC721Factory;
    address public StorageContract;

    address owner;

    constructor(address _VotingContractFactory, address _TreasuryContractFactory, address _DefaultERC20Factory, address _DefaultERC721Factory, address _StorageContract){
        VotingContractFactory = _VotingContractFactory;
        TreasuryContractFactory = _TreasuryContractFactory;
        DefaultERC20Factory = _DefaultERC20Factory;
        DefaultERC721Factory = _DefaultERC721Factory;
        StorageContract = _StorageContract;

        owner = msg.sender;
    }

    modifier only_owner {
        require(msg.sender == owner);
        _;
    }

    event daoCreated(uint256 indexed _index, address VotingContract, address TreasuryContract);
    event erc20Created(address indexed _contractAddress, string _name, string _symbol, uint256 _totalSupply);
    event erc721Created(address indexed _contractAddress, string _name, string _symbol, uint256 _totalSupply);

    function createNewDAO(string memory _daoName, address _votingOpener, address _voter, address _treasuryVotingOpener, address _treasuryVoter, string memory _logoURL, string memory _website) public {
        IVotingContractFactory votingContract = IVotingContractFactory(VotingContractFactory);
        address newVotingContract = votingContract.createVotingContract(_votingOpener, _voter);

        ITreasuryContractFactory treasuryContract = ITreasuryContractFactory(TreasuryContractFactory);
        address newTreasuryContract = treasuryContract.createTreasuryContract(_treasuryVotingOpener, _treasuryVoter);
    
        DAO memory newDAO = DAO({
            index: daoIndex,
            daoName: _daoName,
            votingContract: newVotingContract,
            votingOpener: _votingOpener,
            voter: _voter,
            treasuryVotingContract: newTreasuryContract,
            treasuryVotingOpener: _treasuryVotingOpener,
            treasuryVoter: _treasuryVoter,
            logoURL: _logoURL,
            website: _website
        });

        IStorage _storageContract = IStorage(StorageContract);
        _storageContract.addNewDAO(newDAO);

        emit daoCreated(daoIndex, newVotingContract, newTreasuryContract);

        daoIndex++;
    }

    function getDAOs() public view returns(DAO[] memory) {
        IStorage _storage = IStorage(StorageContract);

        return _storage.getDAOs();
    }

    function createDefaultERC20(string memory _name, string memory _symbol, uint256 _totalSupply) public {
        IDefaultERC20Factory _newERC20 = IDefaultERC20Factory(DefaultERC20Factory);
        address newERC20 = _newERC20.createDefaultERC20(_name, _symbol, _totalSupply, msg.sender);

        emit erc20Created(newERC20, _name, _symbol, _totalSupply);
    }

    function createDefaultERC721(string memory _name, string memory _symbol, uint256 _totalSupply) public {
        IDefaultERC721Factory _newERC721 = IDefaultERC721Factory(DefaultERC721Factory);
        address newERC721 = _newERC721.createDefaultERC721(_name, _symbol, _totalSupply);

        emit erc721Created(address(newERC721), _name, _symbol, _totalSupply);
    } 

    function createTreasuryVoting(address _treasuryVotingContractAddress, string memory _votingName, string memory _votingDescription, address _to, uint256 _amount, address _tokenContract) public {
        ITreasuryVotingContract _treasuryVotingContract = ITreasuryVotingContract(_treasuryVotingContractAddress);
        _treasuryVotingContract.createTreasuryVoting(_votingName, _votingDescription, _to, _amount, _tokenContract);
    }

    function voteTreasury(address _treasuryVotingContractAddress, uint256 _index, bool _vote) public {
        ITreasuryVotingContract _treasuryVotingContract = ITreasuryVotingContract(_treasuryVotingContractAddress);
        _treasuryVotingContract.vote(msg.sender, _index, _vote);
    }

    function getTreasuryVotings(address _treasuryVotingContractAddress) public view returns(TreasuryVoting[] memory){
        ITreasuryVotingContract _treasuryVotingContract = ITreasuryVotingContract(_treasuryVotingContractAddress);
        
        return _treasuryVotingContract.getVotings();
    }

    function getTreasuryVotingResult(address _treasuryVotingContractAddress, uint256 _index) public view returns(uint256, uint256) {
        ITreasuryVotingContract _treasuryVotingContract = ITreasuryVotingContract(_treasuryVotingContractAddress);
        
        return _treasuryVotingContract.getResult(_index);
    }

    function finishTreasuryVoting(address _treasuryVotingContractAddress, uint256 _index) public {
        ITreasuryVotingContract _treasuryVotingContract = ITreasuryVotingContract(_treasuryVotingContractAddress);

        _treasuryVotingContract.finishContract(_index);
    }

    function createGeneralVoting(address _votingContractAddress, string memory _votingName, string memory _votingDescription, string[] memory _choices) public {
        IVotingContract _votingContract = IVotingContract(_votingContractAddress);
        _votingContract.createNewVoting(msg.sender, _votingName, _votingDescription, _choices);
    }

    function voteGeneral(address _votingContractAddress, uint256 _index, string memory _choice) public {
        IVotingContract _votingContract = IVotingContract(_votingContractAddress);
        _votingContract.vote(msg.sender, _index, _choice);
    }

    function getGeneralVotings(address _votingContractAddress) public view returns(Voting[] memory) {
        IVotingContract _votingContract = IVotingContract(_votingContractAddress);
        return _votingContract.getVotings();
    }

    function getGeneralVoteResult(address _votingContractAddress, uint256 _index) public view returns(string[] memory, uint256[] memory) {
        IVotingContract _votingContract = IVotingContract(_votingContractAddress);
        return _votingContract.getResult(_index);
    }

    function changeVotingContractFactory(address _newContract) public only_owner {
        VotingContractFactory = _newContract;
    }

    function changTreasuryContractFactory(address _newContract) public only_owner {
        VotingContractFactory = _newContract;
    }

    function changeDefaultERC20Factory(address _newContract) public only_owner {
        DefaultERC20Factory = _newContract;
    }

    function changeDefaultERC721Factory(address _newContract) public only_owner {
        DefaultERC721Factory = _newContract;
    }

    function changeStorageContract(address _newContract) public only_owner {
        StorageContract = _newContract;
    }
}