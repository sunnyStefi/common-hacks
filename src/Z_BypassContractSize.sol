// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;


contract Victim {
    error Victim_OnlyEOA();

    bool public called = false;

    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function onlyEOA() external {
        if (isContract(msg.sender)) {
            revert Victim_OnlyEOA();
        }
        called = true;
    }
}

contract Attacker {
    constructor(address _victim) {
        //upon creation, the contract size is still 0
        Victim(_victim).onlyEOA();
    }
}

contract NormalContract {
    function tryToCallEOA(address _victim) external {
        Victim(_victim).onlyEOA();
    }
}
