// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice
 * state variable can be modfied just calling a delegatecall
 * with a loop
 */

contract Victim {
    address[] addresses;
    mapping(address => uint256) balances;

    function addBalanceBadForDelegate(address a) public payable {
        //should be not payable
        addresses.push(a);
        balances[a] += msg.value;
    }

    function addBalanceBadForDelegate(address a, uint256 amount) public payable {
        //should be not payable
        addresses.push(a);
        balances[a] += amount;
    }
}

contract Attacker {
    address[] addresses;
    mapping(address => uint256) evilCopyOfBalances;
    Victim victim;

    constructor(address _victim) {
        victim = Victim(_victim);
    }


    function badDelegatecallUse(address[] memory evilAddresses) public payable {
        uint256 length = evilAddresses.length;
        for (uint256 i = 0; i < length;) {
            address(victim).delegatecall(abi.encodeWithSignature("addBalanceBadForDelegate(address)", evilAddresses[i]));
            unchecked {
                i++;
            }
        }
    }


    function balanceSum() public returns (uint256) {
        uint256 length = addresses.length;
        uint256 totalBalance = 0;
        for (uint256 i = 0; i < length;) {
            totalBalance += evilCopyOfBalances[addresses[i]];
            unchecked {
                i++;
            }
        }
        return totalBalance;
    }
}
