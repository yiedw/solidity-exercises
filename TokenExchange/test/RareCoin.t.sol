// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/RareCoin.sol";
import "../src/SkillsCoin.sol";

contract RareCoinTest is Test{
    RareCoin public rareCoin;
    SkillsCoin public skillsCoin;
    address user1 = vm.addr(1);


    function setUp() public {
        rareCoin = new RareCoin("rareCoin","ra");
        skillsCoin = new SkillsCoin("skillsCoin","sk");
    }

    function testApprove() public {
        skillsCoin.approve(address(rareCoin),1000);
        assertEq(skillsCoin.allowance(address(this),address(rareCoin)),1000);
    }

    // function testMint() public {
    //     rareCoin.mint(user1,100);
    //     assertEq(rareCoin.balanceOf(user1),100);
    // }

    function testTrade() public{
        skillsCoin.mint(10000);
        skillsCoin.approve(address(rareCoin),1000);
        rareCoin.trade(address(skillsCoin), 1000);
        assertEq(rareCoin.balanceOf(address(this)),1000);
    }

    
}