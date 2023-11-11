// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice the custom directive will be used to protect the variable usage
 */

contract Victim {
    error Victim_notAMagician();

    address magician;

    //@custom:security write-protection="onlyMagician()"
    uint256 magicProtectedValue;

    constructor(address _magician) {
        magician = _magician;
    }

    function notMagic() public {
        magicProtectedValue = 666;
    }

    function magic() public onlyMagician {
        magicProtectedValue = 1;
    }

    modifier onlyMagician() {
        if (msg.sender != magician) {
            revert Victim_notAMagician();
        }
        _;
    }

    //for testing
    function getMagicProtectedValue() public returns (uint256) {
        return magicProtectedValue;
    }
}
