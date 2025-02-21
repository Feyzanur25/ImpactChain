// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Storage {
    address private owner;

    mapping(address => bool) public isStorable;

    event DAOAdded(
        uint256 indexed index,
        string daoName,
        address indexed votingContract
    );
    event DAORemoved(uint256 indexed index, string daoName);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyStorable() {
        require(isStorable[msg.sender], "Caller is not a storable contract");
        _;
    }

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
        bool isActive;
    }

    DAO[] public daos;

    function addStorableContract(address _contractAddress) public onlyOwner {
        isStorable[_contractAddress] = true;
    }

    function removeStorableContract(address _contractAddress) public onlyOwner {
        isStorable[_contractAddress] = false;
    }

    function addNewDAO(DAO memory _newDAO) public onlyStorable {
        _newDAO.index = daos.length;
        _newDAO.isActive = true;
        daos.push(_newDAO);

        emit DAOAdded(_newDAO.index, _newDAO.daoName, _newDAO.votingContract);
    }

    function removeDAO(uint256 _index) public onlyStorable {
        require(_index < daos.length, "DAO index out of bounds");
        require(daos[_index].isActive, "DAO is already inactive");

        daos[_index].isActive = false;
        emit DAORemoved(_index, daos[_index].daoName);
    }

    function getDAOs() public view returns (DAO[] memory) {
        return daos;
    }

    function getActiveDAOs() public view returns (DAO[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < daos.length; i++) {
            if (daos[i].isActive) {
                activeCount++;
            }
        }

        DAO[] memory activeDAOs = new DAO[](activeCount);
        uint256 j = 0;
        for (uint256 i = 0; i < daos.length; i++) {
            if (daos[i].isActive) {
                activeDAOs[j] = daos[i];
                j++;
            }
        }

        return activeDAOs;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
