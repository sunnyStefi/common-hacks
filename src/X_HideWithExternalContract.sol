// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice Hiding malicious code with External Contract
 */

contract Victim {
    Lib accomplice;

    constructor(address _accomplice) {
        accomplice = Lib(_accomplice);
    }

    function callLog() public {
        accomplice.log();
    }
}

contract Lib {
    event Lib_Log();

    function log() public {
        emit Lib_Log();
    }
}

contract Attacker {
    event Attacker_Log();

    function log() public {
        emit Attacker_Log();
    }
}


