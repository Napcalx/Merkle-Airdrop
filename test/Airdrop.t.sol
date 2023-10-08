// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Airdrop} from "../src/Airdrop.sol";
import {Assist, Information, Qualified} from "./Assist.sol";

contract AirdropTest is Assist {
    Airdrop public airdrop;

    event successfulClaim(address account, uint256 amount);

    bytes32 root =
        0xf7992317de2bc61f25971e0074b43eab675ffa0e353ae7c861e1600cb4470df2;

    Information info;
    Qualified quali;

    function setUp() public {
        airdrop = new Airdrop(root);
        (quali, info) = getInfo("0");
    }

    function testUserCantClaimTwice() public {
        claim(info.proof, quali.user, quali.amount);
        vm.expectRevert("You have Already claimed");
        claim(info.proof, quali.user, quali.amount);
    }

    function testIncorrectProof() public {
        (Information memory In) = getInfo(3);
        vm.expectRevert("Invalid Verification");
        claim(In.proof, quali.user, quali.amount);
    }

    function testIncorrectAccount() public {
        vm.expectRevert("Invalid Account");
        claim(info.proof, vm.addr(200), quali.amount);
    }

    function testIncorrectAmount() public {
        vm.expectRevert("Invalid Amount");
        claim(info.proof, quali.user, 100);
    }

    function testClaimSuccessful() public {
        claim(info.proof, quali.user, quali.amount);
        assertTrue(airdrop.claimed(quali.user));
    }

    function testMintExpectedAmount() public {
        uint balanceBefore = airdrop.balanceOf(quali.user);
        claim(info.proof, quali.user, quali.amount);
        uint balanceAfter = airdrop.balanceOf(quali.user);
        assertEq(balanceAfter - balanceBefore, quali.amount);
    }

    function testEventEmittdAfterClaim() public  {
        vm.expectEmit(true, true, false, false);
        emit successfulClaim(quali.user, quali.amount);
        claim(info.proof, quali.user, quali.amount);
    }

    function claim(bytes32[] memory proof, address user_, uint amount_) 
    internal returns (bool success) {
        success = airdrop.claim(proof, user_, amount_);
    }
