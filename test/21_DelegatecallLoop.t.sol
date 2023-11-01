// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Victim, Attacker} from "../src/21_DelegatecallLoop.sol";

contract DelegatecallLoopTest is Test {
    Victim public victim;
    Attacker public attacker;
    address[] evilAddresses;
    address public evil1 = makeAddr("EVIL1");
    address public evil2 = makeAddr("EVIL2");

    function setUp() public {
        victim = new Victim();
        attacker = new Attacker(address(victim));
        vm.deal(address(attacker), 1 ether);
        evilAddresses.push(evil1);
        evilAddresses.push(evil2);
    }

    function test_badDelegateLoop() public {
        attacker.badDelegatecallUse{value: 1 ether}(evilAddresses); //value will not be modified by delegatecall
        assertEq(attacker.balanceSum(), 2 ether);
    }

}
