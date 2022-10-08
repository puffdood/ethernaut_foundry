// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        // We updated this with unchecked so it behaves as per the original code
        // written to be compiled with solidity ^0.6.0
        // As of ^0.8.0, arithmetic ops will revert on over/underflow
        // On ^0.6.0, it will wrap
        unchecked {
            require(balances[msg.sender] - _value >= 0);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}
