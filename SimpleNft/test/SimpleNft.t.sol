// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleNft} from "../src/SimpleNft.sol";

contract SimpleNftTest is Test {
    SimpleNft public _simpleNft;

    address test = vm.addr(1);
    address test2 = vm.addr(2);

    function setUp() public {
        _simpleNft = new SimpleNft();
        // simpleNft._owners=address(this);
    }

    function testMint() public {
        vm.startPrank(test);
        _simpleNft.mint(0);
        _simpleNft.mint(23);
        console.log("ASdf");

        vm.expectRevert("Already minted");
        _simpleNft.mint(0);

        vm.expectRevert("_tokenId too Large");
        _simpleNft.mint(1001);

        console.log(_simpleNft.balanceOf(test));
    }

    function testOwnerOf() public {
        vm.prank(test);
        _simpleNft.mint(0);
        _simpleNft.ownerOf(0);

        vm.expectRevert("No such token");
        _simpleNft.ownerOf(1);
    }

    function testTransfreFrom() public {
        vm.startPrank(test);
        _simpleNft.mint(0);
        _simpleNft.transferFrom(test, test2, 0);

        vm.expectRevert();
        _simpleNft.transferFrom(test, test2, 1);

        vm.expectRevert();
        _simpleNft.transferFrom(address(this), test2, 0);
    }

    function testTokenURI() public {
        _simpleNft.mint(10);
        console.log(_simpleNft.tokenURI(10));
    }
}
