// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice
 * When transfer from is not a verified contract, a malicious actor can send money to himself
 */

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TOK") {
        _mint(msg.sender, 100 ether);
    }
}

contract Victim {}
