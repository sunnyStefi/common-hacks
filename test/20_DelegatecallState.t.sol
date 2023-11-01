// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Lib, Victim, Attacker} from "../src/20_DelegatecallState.sol";

contract DelegatecallStateTest is Test {
    Victim public victim;
    Attacker public attacker;
    Lib public lib;

    function setUp() public {
        lib = new Lib();
        victim = new Victim();
        attacker = new Attacker(address(victim));
    }

    function test_attackDelegateState() public {
        victim.getComplicatedSquareArea(address(lib), 3);
        assertEq(victim.area(), 9);
        attacker.attack(address(lib), 2);
        assertEq(victim.area(), 4);
    }
}
