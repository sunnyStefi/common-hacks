// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @notice Victim is multisig wallet
 * Same sig can be use multiple times if nonce is not used
 */

// import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Victim {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address[2] public owners;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(address _to, uint256 _amount, bytes[2] memory _sigs) external {
        bytes32 txHash = keccak256(abi.encodePacked(_to, _amount));
        require(_checkSigs(_sigs, txHash), "invalid sig");

        (bool sent,) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash) public view returns (bool) {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint256 i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                return false;
            }
        }

        return true;
    }
}
