// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

/**
 * @notice extracting a function’s arguments from a contract’s calldata
 *
 * shr(16) -> 8 ec.. diminishes power of 2
 *
 * both functions shift 16 of 1 bit
 */
contract IncorrectShiftTest is Test {
    function setUp() public {}

    function userUsesCorrectShift() public pure returns (uint40) {
        uint40 calldataExample = 16;
        assembly {
            calldataExample := shr(1, calldataExample)
        }
        return calldataExample;
    }

    function userUsesWrongShift() public pure returns (uint40) {
        uint40 calldataExample = 1;
        assembly {
            calldataExample := shr(calldataExample, 16)
        }
        return calldataExample;
    }

    function test_userShift() public {
        assertEq(userUsesCorrectShift(), userUsesWrongShift());
    }
}
