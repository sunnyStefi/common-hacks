# Solidity by example Hacks

Playground for all (92) Slither Detection Hacks.
Each attacked vulnerability is reproduced inside its contract name and Detactor Number.

In test folder, the attack simulation takes place.

## Code patterns on Victim Contracts in order to avoid common attacks

While writing potential victim contracts:

**# 12 Suicidal**

1. UNEXPECTED ACTION: Considering how the contract logic react to unexpected receiving money amount (call, selfdestruct)
2. BEST PRACTICE: Be sure that state variables and functions are called to deposit and check balances

**# 20 Delegatecall State**

1. UNEXPECTED ACTION: Overwrite a victim state variable thorugh an external stateful library
2. BEST PRACTICE: Use stateless libraries

**# 21 Delegatecall Loop** 

1. UNEXPECTED ACTION: msg.value 
2. BEST PRACTICE: The called function does not have payable - do not use msg.value (similar to suicidal address(this.balance))
--TO CLARIFY 9looks identical to # 20--

**# 25 # 45 Reentrancy**

1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
2. BEST PRACTICE: CEI not CIE


**# 25 # 45 Reentrancy**

1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
2. BEST PRACTICE: Don't use blockhash and block.timestamp as source of randomness

