// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Attacker, NormalContract} from "../src/Z_BypassContractSize.sol";

contract BypassContractSizeTest is Test {
    Victim public victim;
    Attacker public attacker;
    NormalContract public normalContract;

    function setUp() public {
        victim = new Victim();
        normalContract = new NormalContract();
    }

    function test_attackBypassContractSize() public {
        attacker = new Attacker(address(victim));
        assertEq(victim.called(), true);
    }

    function test_normalContractCantCallEOA() public {
        assertEq(victim.called(), false);
    }
}
