// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice
 *
 * 1. UNEXPECTED ACTION: Overwrite a victim state variable thorugh an external stateful library
 * 2. BEST PRACTICE: Use stateless libraries
 *
 * 3 players
 * 1. Library that maintain a states: every time this state is modified, the caller's first slot is modified too
 * 2. Victim makes a delegate call to the library and saves it into its first slot state
 * 3. Attacker can also change Victim state calling the Library's function
 */

contract Lib {
    uint256 public area; //or more sensitive information!

    function getSquareArea(uint256 side) public {
        area = side * side; // PREVENTION: this must be stateless and just return the calculation
    }
}

contract Victim {
    uint256 public area; //2. we want to overwrite this value from the Attacker contract

    function getComplicatedSquareArea(address lib, uint256 side) public {
        (bool success, bytes memory data) = lib.delegatecall(abi.encodeWithSignature("getSquareArea(uint256)", side)); // this will change storage slot #2
    }
}

contract Attacker {
    //same state variables as victim
    uint256 public area;

    Victim public victim;

    constructor(address _victim) {
        victim = Victim(_victim);
    }

    function attack(address lib, uint256 evilNumber) public {
        victim.getComplicatedSquareArea(lib, evilNumber);
    }
}
