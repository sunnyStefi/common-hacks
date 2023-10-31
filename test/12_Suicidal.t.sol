// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Attacker} from "../src/12_Suicidal.sol";

contract SuicidalTest is Test {
    Victim public victim;
    Attacker public attacker;
    address public alice = makeAddr("ALICE");

    function setUp() public {
        victim = new Victim();
        attacker = new Attacker(victim);

        // 1) give ether to test user and attacker
        vm.deal(alice, 1 ether);
        vm.deal(address(attacker), 10 ether);

        // 2) user deposit 1 ether
        vm.prank(alice);
        victim.deposit{value: 1 ether}();
    }

    function test_attackSuicidal() public {
        // 3) attacker deposit 10 ether: no one will win the game / can claim rewards

        vm.startPrank(address(attacker));
        uint256 expectedTotalAmountDeposited = 2 ether;
        assertEq(expectedTotalAmountDeposited, address(victim).balance);
        attacker.attack();
        assertEq(address(attacker).balance,0);
        assertEq(address(victim).balance, 11 ether); // it has the attacker + alice money > the victim contract is now broken
        vm.stopPrank();
    }
}
