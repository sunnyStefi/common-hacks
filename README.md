# Solidity by example Hacks

Playground for all (92) Slither Detection Hacks.
Each attacked vulnerability is reproduced inside its contract name and Detactor Number.

In test folder, the attack simulation takes place.

## Code patterns on Victim Contracts in order to avoid common attacks

While writing potential victim contracts:

**12_Suicidal** 
1. UNEXPECTED ACTION: Considering how the contract logic react to unexpected receiving money amount (call, selfdestruct)
2. BEST PRACTICE: Be sure that state variables and functions are called to deposit and check balances
**25-45_Reentrancy** 
1. UNEXPECTED ACTION: Exploitation of state variables through a callback function
2. BEST PRACTICE: CEI not CIE 

