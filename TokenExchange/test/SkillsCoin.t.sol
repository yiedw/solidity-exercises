// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SkillsCoin.sol";

contract SkillsCoinTest is Test{
    SkillsCoin public skillsCoin;
    // address user1 = vm.addr(1);


    function setUp() public {
        skillsCoin = new SkillsCoin("skillsCoin","sk");
    }

function testMint() public {
    skillsCoin.mint(10000);
    assertEq(skillsCoin.balanceOf(address(this)), 10000);
}

// function testApprove(){
//     skillsCoin.approve(address(this),1000);
//     assertEq(skillsCoin.allowance[address(this)][],, right);
// }
    
}