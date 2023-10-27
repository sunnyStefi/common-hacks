// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyVictim, ReentrancyAttacker} from "../src/45_ReentrancyCross.sol";

contract ReentrancyCrossTest is Test {
    ReentrancyVictim public victim;
    ReentrancyAttacker public attacker;
    address public good_alice = makeAddr("ALICE");
    address public good_bob = makeAddr("BOB");
    address public evil_carl = makeAddr("EVIL_CARL");

    function setUp() public {
        victim = new ReentrancyVictim();
        attacker = new ReentrancyAttacker(address(victim), evil_carl);

        // 1) give ether to test users and attacker
        vm.deal(good_alice, 1 ether);
        vm.deal(good_bob, 1 ether);
        vm.deal(address(attacker), 1 ether);

        // 2) two unaware users deposit 1 ether
        vm.prank(good_alice);
        victim.deposit{value: 1 ether}();
        vm.prank(good_bob);
        victim.deposit{value: 1 ether}();
    }

    function test_crossFunctionAttack() public {
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();
        assertEq(address(attacker).balance + victim.getBalances(evil_carl), 2 ether);
    }
}
