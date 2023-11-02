# Solidity by example Hacks

This repo is a recap for 
- all (92) Slither Detection Hacks (in progress)
- Hacks listed inside Solidity by Example (in progress)
- not So smart contract (to do)

Each attacked vulnerability is reproduced inside its contract name and Slither Detactor Number.

In src folder, the Victim and Attacker are build. In the test folder, the attack simulation takes place.

## Code patterns on Victim Contracts in order to avoid common attacks

While writing potential victim contracts:

**#12 Suicidal**

1. UNEXPECTED ACTION: Considering how the contract logic react to unexpected receiving money amount (call, selfdestruct)
2. BEST PRACTICE: Be sure that state variables and functions are called to deposit and check balances

**#20 Delegatecall State**

1. UNEXPECTED ACTION: Overwrite a victim state variable thorugh an external stateful library
2. BEST PRACTICE: Use stateless libraries

**#21 Delegatecall Loop** 

1. UNEXPECTED ACTION: msg.value 
2. BEST PRACTICE: The called function does not have payable - do not use msg.value (similar to suicidal address(this.balance))
--TO CLARIFY 9looks identical to # 20--

**#25 #45 Reentrancy**

1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
2. BEST PRACTICE: CEI not CIE

**#47 TxOrigin**

1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
2. BEST PRACTICE: Use msg.sender instead of tx.origin for authorization


**#66 Randomness with blockhash and timestamp**

1. UNEXPECTED ACTION: Copy the variables to fake the randomness
2. BEST PRACTICE: Don't use blockhash and block.timestamp as source of randomness

**#75 DOS**

1. WEAK SITUATION: contract logic. It sends money back to the user with `call`.
2. UNEXPECTED ACTION: the attacker can invoke the same function that contains call but he does not have a fallback function.
3. RESULT OF UNEXPECTED ACTION: Performing the function that contains `call` will always raise an error: `call` cannot send funds to the next sender. The logic after the call function cannot be executed anymore.
3. BEST PRACTICE: CEI and contract logic. If CEI is impossible, do not mix code that send funds inside other logic, but let the user withdraw separately.

