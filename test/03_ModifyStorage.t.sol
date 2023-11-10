// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim} from "../src/03_ModifyStorage.sol";

contract ModifyStorageTest is Test {
    Victim public victim;

    function setUp() public {
        victim = new Victim();
    }

    function test_attackUpdateStorage() public {
        victim.canUpdateStorage();
        victim.cannotUpdateStorage();
        assertEq(victim.getArr1(), 1);
    }
}
