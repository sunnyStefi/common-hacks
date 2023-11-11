// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim} from "../src/08_ProtectedVars.sol";

contract ProtectedVarsTest is Test {
    Victim public victim;
    address magician = makeAddr("magician");

    function setUp() public {
        victim = new Victim(magician);
    }

    function test_attackProtected() public {
        vm.prank(magician);
        victim.magic();
        assertEq(victim.getMagicProtectedValue(), 1);
        victim.notMagic();
        assertEq(victim.getMagicProtectedValue(), 666);
    }
}
