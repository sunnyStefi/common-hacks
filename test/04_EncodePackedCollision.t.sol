// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";

contract EncodePackedCollisionTest is Test {
    string public name;
    string public surname;
    string public constant CORRECT_NAME = "ali";
    string public constant CORRECT_SURNAME = "ce";
    string public constant INCORRECT_NAME = "a";
    string public constant INCORRECT_SURNAME = "lice";
    address public alice = makeAddr("alice");
    address public evil_carl = makeAddr("evil_carl");

    function setUp() public {
        vm.startPrank(alice);
        name = CORRECT_NAME;
        surname = CORRECT_SURNAME;
        vm.stopPrank();
    }

    function test_attackHash() public {
        bytes32 expectedHash = keccak256(abi.encodePacked(name, surname));
        vm.startPrank(evil_carl);
        name = INCORRECT_NAME;
        surname = INCORRECT_SURNAME;
        bytes32 maliciousHash = keccak256(abi.encodePacked(name, surname));
        assertEq(maliciousHash, expectedHash);
        vm.stopPrank();
    }
}
