// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice make function that modify storage internal
 * and be aware of their usage
 */

contract Victim {
    uint256[1] public arr_1;

    function canUpdateStorage(uint256[1] storage _array1) internal {
        _array1[0] = 1;
    }

    function cannotUpdateStorage(uint256[1] memory _array1) internal {
        _array1[0] = 2;
    }

    function getArr1() public returns (uint256) {
        return arr_1[0];
    }

    function canUpdateStorage() public {
        canUpdateStorage(arr_1);
    }

    function cannotUpdateStorage() public {
        cannotUpdateStorage(arr_1);
    }
}
