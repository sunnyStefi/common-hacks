// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim, Attacker} from "../src/X_DOS.sol";

contract X_DOSTest is Test {
    Victim public victim;
    Attacker public attacker;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        vm.deal(address(this), 0.1 ether);
        victim = new Victim{value: 0.1 ether}();
        attacker = new Attacker(address(victim));
        vm.deal(alice, 1 ether);
        vm.deal(bob, 2 ether);
        vm.deal(address(attacker), 4 ether);

        vm.prank(alice);
        victim.claimThrone{value: 1 ether}();
        vm.prank(bob);
        victim.claimThrone{value: 2 ether}();
    }

    function test_attackDOS() public {
        assertEq(victim.king(), bob);
        attacker.attackWithLogic{value: 3 ether}(); // he spends 3 eth to DOS the victim
        console.log(victim.balance());
        // assertEq(victim.king(), address(attacker));
    }
}
