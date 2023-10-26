// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {Reentrancy} from "../src/Reentrancy.sol";

contract ReentrancyTest is Test {
    Reentrancy public victim;

    function setUp() public {
        victim = new Reentrancy();
    }

    function test_() public {}
}
