// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DefaultERC20.sol";

contract DefaultERC20Factory {
    function createDefaultERC20(string memory _name, string memory _symbol, uint256 _totalSupply, address _creator) public returns(address){
        DefaultERC20 newERC20 = new DefaultERC20(_name, _symbol, _totalSupply, _creator);
        
        return address(newERC20);
    }
}