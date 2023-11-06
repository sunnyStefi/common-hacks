// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Lib, Attacker} from "../src/X_HideWithExternalContract.sol";

contract HideWithExternalContractTest is Test {
    Victim public victim;
    Attacker public attacker;
    Lib public lib;

    function setUp() public {}

    function test_attackHideWithExternalContract() public {
        lib = new Lib();
        attacker = new Attacker();

        //the victim sets the wrong address in the constructor
        victim = new Victim(address(attacker));

        //the malicious call is performed
        victim.callLog();
    }
}
