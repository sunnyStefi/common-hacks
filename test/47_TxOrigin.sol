// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Attacker} from "../src/47_TxOrigin.sol";

contract TxOriginTest is Test {
    Victim public victim;
    Attacker public attacker;
    address public alice = makeAddr("alice");
    address public evil_carl = makeAddr("evil_carl");
    uint256 amountToBeStolen = 1 ether;

    function setUp() public {
        //fakes msg.sender and tx.origin respectively
        //if we dont specify the 2nd param, the tx.origin would have been the contract that deploys TxOriginTest
        vm.prank(alice, alice);
        victim = new Victim();

        vm.prank(evil_carl);
        attacker = new Attacker(address(victim));
        vm.deal(address(victim), amountToBeStolen);
    }

    function test_attackPhishing() public {
        vm.startPrank(alice, alice);
        attacker.attack();
        assertEq(evil_carl.balance, amountToBeStolen);
        vm.stopPrank();
    }
}
