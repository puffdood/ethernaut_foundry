// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        // We updated this with unchecked so it behaves as per the original code
        // written to be compiled with solidity ^0.6.0
        // As of ^0.8.0, arithmetic ops will revert on over/underflow
        // On ^0.6.0, it will wrap
        unchecked {
            if (balances[msg.sender] >= _amount) {
                (bool result, ) = msg.sender.call{value: _amount}("");
                if (result) {
                    _amount;
                }
                balances[msg.sender] -= _amount;
            }
        }
    }

    receive() external payable {}
}
