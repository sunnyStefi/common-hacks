// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Victim} from "../src/Y_Frontrunning.sol";

contract FrontrunningTest is Test {
    Victim public victim;
    address public alice = makeAddr("alice");
    address public evil_carl = makeAddr("evil_carl");
    string constant secretAnswer = "answer";

    function setUp() public {
        vm.txGasPrice(1);
        victim = new Victim();
        vm.deal(address(victim), 1 ether);
        vm.prank(alice);
        victim.findSecret(secretAnswer);
    }

    function test_Frontrunning() public {
        vm.txGasPrice(100);
        vm.prank(evil_carl);
        victim.findSecret(secretAnswer);
        console.log(evil_carl.balance);
        console.log(alice.balance);
    }
}
