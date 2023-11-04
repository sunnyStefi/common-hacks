// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice Frontrunning: benefit someone else's work.
 * Before a tx is mined, it waits in mempool.
 * An attacker can send another tx, pay more gas, gets precedence and preceed the victim tx.
 */

contract Victim {
   
}

