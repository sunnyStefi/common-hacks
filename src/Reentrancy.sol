// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @notice
 *
 * - Manipulation: victim state/balance
 *
 * - Exploited cycle (victim)
 * 1) check user's (attacker) balance
 * 2) send funds (and create a time window)
 * 3) update the user's (attacker) balance
 *
 * - Exploiter cycle (attacker)
 * 1) asks victim to transfer funds to him (witdraw)
 * 2) victim starts its exploited cycle
 * 3) attacker receives its funds
 * 4) between Victim's point 2) and 3), the attacker balance is still positive
 * so he's eligible to withdraw again
 * 5) he calls a recursive callback function to keep withdrawing funds
 *
 *
 * - Prevention:
 * 1) CEI instead of CIE -> update the state changes before calling external contracts
 * 2) modifiers
 */
contract Reentrancy {
    error Reentrancy_balanceIsLow();
    error Reentrancy_callFailed();

    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawAllAmount() public {
        uint256 userBalance = balances[msg.sender];
        // 1) Check
        if (userBalance == 0) {
            revert Reentrancy_balanceIsLow();
        }
        // 2) Interacion
        (bool success,) = msg.sender.call{value: userBalance}("");
        if (!success) {
            revert Reentrancy_callFailed();
        }
        // 3) Effect
        balances[msg.sender] = 0;
    }
}
