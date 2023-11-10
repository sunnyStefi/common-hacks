# Common Hacks

This repo is a recap for 
- all (92) Slither Detection Hacks (in progress)
- Hacks listed inside Solidity by Example
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

1. ACTORS: Victim user, Victim contract, Attacker user, Attacker contract
2. WEAK SITUATION: the onlyOwner modifier is tx.origin
3. UNEXPECTED ACTION: phishing. The user calls the attacker's function 
4. RESULT OF UNEXPECTED ACTION: the attacker's function checks the tx.origin (the user), ingnoring that the one who called the function (msg.sender) is the attacker
5. BEST PRACTICE: use msg.sender instead of tx.origin for authorization


**#66 Randomness with blockhash and timestamp**

1. UNEXPECTED ACTION: Copy the variables to fake the randomness
2. BEST PRACTICE: Don't use blockhash and block.timestamp as source of randomness

**#75 DOS**

1. WEAK SITUATION: contract logic. It sends money back to the user with `call` then it executes state modifications.
2. UNEXPECTED ACTION: the attacker can invoke the same function that contains call but he does not have a fallback function.
3. RESULT OF UNEXPECTED ACTION: Performing the function that contains `call` will always raise an error: `call` cannot send funds to the next sender. The logic after the call function cannot be executed anymore.
3. BEST PRACTICE: CEI and contract logic. If CEI is impossible, do not mix code that send funds inside other logic, but let the user withdraw separately.

**#X Hide Malicious code with External Contract**

1. ACTORS: Victim contract, Victim user, Attacker Contract, Neutral Contract
2. WEAK SITUATION: Victim contract uses an address in a constructor to instantiate a Neutral contract, then it calls a function in that contract
3. UNEXPECTED ACTION: An attacker contract is made as an exact copy of Victim contract, except of the behaviour of the called function. Then, the Victim User deploys the contract with that malicious address. (Or the contracts are deployed at the same address).
4. RESULT OF UNEXPECTED ACTION: the function now points to the Attacker Contract's one, and performs the malicious code.
5. BEST PRACTICE: Initialize a contract in the params with the correct type and make the address of the external contract public.

**#Y Displacement Frontrunning**

1. ACTORS: Victim user, Attacker user
2. WEAK SITUATION: The victim user submits a tx that gets money by a contract
3. UNEXPECTED ACTION: The Attacker puts more gas inside his tx and he gets priority inside the mempool. He outbids the user.
4. RESULT OF UNEXPECTED ACTION: the attacker receives the money that was supposed to be sent to the User
5. BEST PRACTICE: Minimizing the relevance of transaction ordering or timing inside the contract logic. Batch auctions implementations, defining a maximum or minimum acceptable price range on a trade, commit and reveal scheme. Submarine send

**#Z Bypass Contract Size**

1. ACTORS: Victim contract, Attacker contract
2. WEAK SITUATION: Victim contract uses contract size (extcodesize) to check if a function can be performed
3. UNEXPECTED ACTION: Attacker calls the weak function inside the constructor, where its size is still 0
4. RESULT OF UNEXPECTED ACTION: Attacker can impersonate EOA inside the costructor
5. BEST PRACTICE: 

**#W Signature Replay**

1. ACTORS: Victim Wallet, Attacker user
2. WEAK SITUATION: the wallet does not encode the signature with nonce txHash = keccak(abi.encodePacked(_to, _amount))
3. UNEXPECTED ACTION: attacker will send the tx multiple times
4. RESULT OF UNEXPECTED ACTION: drain funds
5. BEST PRACTICE: always encode signature with nonce txHash = keccak(abi.encodePacked(_to, _amount, _nonce))

**# TEMPLATE**

1. ACTORS:
2. WEAK SITUATION:
3. UNEXPECTED ACTION:
4. RESULT OF UNEXPECTED ACTION:
5. BEST PRACTICE:
