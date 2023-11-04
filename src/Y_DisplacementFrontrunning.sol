// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice Frontrunning: benefit someone else's work.
 * Before a tx is mined, it waits in mempool.
 * An attacker can send another tx, pay more gas, gets precedence and preceed the victim tx.
 */

contract Victim {
    error Victim_IncorrectAnswer();

    bytes32 public constant hash = 0x72713d2d8ce8ee141e4e6c2cea57d07d08f80cf040c0785cb486d47981c38657;

    constructor() payable {}


    function findSecret(string memory answer) public {
        if (hash != keccak256(abi.encodePacked(answer))) {
            revert Victim_IncorrectAnswer();
        }

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable{}
}

/**
 * The attack is executed with cast inside anvil
 *
 *
 */
