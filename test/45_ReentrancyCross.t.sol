// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyVictimFunction, ReentrancyVictimContract, ReentrancyAttacker} from "../src/45_ReentrancyCross.sol";

contract ReentrancyCrossTest is Test {
    ReentrancyVictimFunction public victimFunction;
    ReentrancyVictimContract public victimContract;
    ReentrancyAttacker public attacker;
    address public good_alice = makeAddr("ALICE");
    address public good_bob = makeAddr("BOB");
    address public evil_carl = makeAddr("EVIL_CARL");

    function setUp() public {
        victimFunction = new ReentrancyVictimFunction();
        victimContract = new ReentrancyVictimContract();
        attacker = new ReentrancyAttacker(address(victimFunction),address(victimContract), evil_carl);

        // 1) give ether to test users and attacker
        vm.deal(good_alice, 2 ether);
        vm.deal(good_bob, 2 ether);
        vm.deal(address(attacker), 2 ether);

        // 2) two unaware users deposit 1 ether
        vm.prank(good_alice);
        victimFunction.deposit{value: 1 ether}();
        victimContract.buyOnePokemon{value: 1 ether}();
        vm.prank(good_bob);
        victimFunction.deposit{value: 1 ether}();
        victimContract.buyOnePokemon{value: 1 ether}();
        vm.prank(address(attacker));
        victimContract.buyOnePokemon{value: 1 ether}();
    }

    function test_crossFunctionAttack() public {
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}(ReentrancyAttacker.CrossAttackType.FUNCTION);
        assertEq(address(attacker).balance + victimFunction.getBalances(evil_carl), 2 ether);
    }

    function test_crossContractAttack() public {
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}(ReentrancyAttacker.CrossAttackType.CONTRACT);
        assertEq(attacker.getPokemonAmount(address(attacker)) + attacker.getPokemonAmount(address(evil_carl)), 1 );
    }
}
