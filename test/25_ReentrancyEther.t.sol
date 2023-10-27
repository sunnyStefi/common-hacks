// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyVictim, ReentrancyAttacker} from "../src/25_ReentrancyEther.sol";

contract ReentrancyEtherTest is Test {
    ReentrancyVictim public victim;
    ReentrancyAttacker public attacker;
    address public alice = makeAddr("ALICE");
    address public bob = makeAddr("BOB");

    function setUp() public {
        victim = new ReentrancyVictim();
        attacker = new ReentrancyAttacker(address(victim));

        // 1) give ether to test users and attacker
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(address(attacker), 1 ether);

        // 2) two unaware users deposit 1 ether
        vm.prank(alice);
        victim.deposit{value: 1 ether}();
        vm.prank(bob);
        victim.deposit{value: 1 ether}();
    }

    function test_attack() public {
        vm.prank(address(attacker));
        attacker.attack{value: 0.1 ether}();
        console.log(address(victim).balance);
        assertEq(address(attacker).balance, 3 ether);
    }
}
