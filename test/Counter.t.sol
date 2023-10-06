// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "lib/forge-std/src/Test.sol";
import {Airdrop} from "../src/Airdrop.sol";

contract AirdropTest is Test {
    Airdrop public airdrop;
    using stdJson for string;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }
    bytes32 root =
        0xc87618c6c49eb4b0825fe2b7323eb2d0a34647d57571acbc0eed60825db81123;

    address user1 = 0x244fe02fbcf4db4ad96063b161f00e444fc54011;
    uint user1Amt = 30000000000000;

    Result public result;

    function setUp() public {
        airdrop = new Airdrop(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");
        string memory json = vm.readFile(path);

        bytes memory res = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );

        result = abi.decode(res, (Result));
    }

    // test the user cannot claim twice (claim once , then claim again)
    function testUserCantClaimTwice() public {
        _claim();
        vm.expectRevert(AddressHasClaimed());
        _claim();
    }

    function testClaim() public {
        bool success = _claim();
        assertEq(airdrop.balanceOf(user1), user1Amt);

        assertTrue(success);
    }

    function _claim() internal returns (bool success) {
        success = airdrop.claim(result.proof, user1, user1Amt);
    }
}
