// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Attacker} from "../src/66_BlockTimestamp.sol";

contract BlockTimestampTest is Test {
    Victim public victim;
    Attacker public attacker;
    address public alice = makeAddr("ALICE");

    function setUp() public {
        victim = new Victim();
        attacker = new Attacker();

        vm.deal(address(victim), 100 ether);
    }

    function test_attackBlockTimestamp() public {
        attacker.attack(victim);
        assertEq(address(attacker).balance, 1 ether);
        assertEq(address(victim).balance, 99 ether);
    }
}
