// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DefaultERC721.sol";

contract DefaultERC721Factory {
    function createDefaultERC721(string memory _name, string memory _symbol, uint256 _totalSupply) public returns(address) {
        DefaultERC721 newERC721 = new DefaultERC721(_name, _symbol, _totalSupply);

        return address(newERC721);
    }
}