// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DongToken} from "../src/DongToken.sol";
import {Vesting} from "../src/Vesting.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract VestingTest is Test {
    // DONG TOKEN
    DongToken public dongToken;
    Vesting public vesting;

    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address owner = makeAddr("owner");
    address me = makeAddr("me");
    // address you = makeAddr("you");

    uint256 lockTimestamp = 1949184000; // 2031.11.01
    uint256 vestingEndTimestamp = 1980806400; // 2032.11.01
    uint256 purchaseEndTimestamp = 1917648000; // 2030.10.08

    uint256 tokenPrice = 10;

    function setUp() public {
        deal(usdc, owner, 1000e6);
        deal(usdc, me, 10000e6);
        // console.log(IERC20(usdc).balanceOf(owner));
        // console.log(IERC20(usdc).balanceOf(me));
        // deal(usdc, you, 10e6);

        vm.startPrank(owner);
        dongToken = new DongToken("DongToken", "dt");
        vesting = new Vesting();
        vm.stopPrank();
    }

    function testMintDt() public {
        vm.prank(owner);
        dongToken.mint(owner, 100e6);
        // console.log(IERC20(address(dongToken)).balanceOf(owner));
    }

    function testDeposit() public {
        vm.startPrank(owner);
        dongToken.mint(owner, 100e6);
        dongToken.approve(address(vesting), 1000e18);

        vesting.depositToken(
            address(dongToken), 1000e18, tokenPrice, lockTimestamp, vestingEndTimestamp, purchaseEndTimestamp
        );
        // console.log(IERC20(address(dongToken)).balanceOf(address(vesting)));

        // contract owner check
        dongToken.mint(me, 100e6);
        vm.stopPrank();
        vm.startPrank(me);
        dongToken.approve(address(vesting), 1000e18);

        vm.expectRevert("not owner!");
        vesting.depositToken(
            address(dongToken), 1000e18, tokenPrice, lockTimestamp, vestingEndTimestamp, purchaseEndTimestamp
        );
        vm.stopPrank();
    }

    function testTokenPurchase() public {
        vm.startPrank(owner);
        dongToken.mint(owner, 1000e6);
        dongToken.approve(address(vesting), 10000e18);
        vesting.depositToken(
            address(dongToken), 10000e18, tokenPrice, lockTimestamp, vestingEndTimestamp, purchaseEndTimestamp
        );
        // console.log(vesting.returnTokenAmount(address(dongToken)));

        vm.stopPrank();
        vm.startPrank(me);
        IERC20(address(usdc)).approve(address(vesting), 10000e6);
        // console.log(uint256(100e6 * 10 * 1e12));
        vesting.tokenPurchase(address(dongToken), 100e6);
        // console.log(vesting.returnUnclaimToken(address(dongToken)));
        // console.log(vesting.returnTokenAmount(address(dongToken)));

        // 남은 물량보다 더 사려고할때 테스트
        vm.expectRevert("lack of token");
        vesting.tokenPurchase(address(dongToken), 1000e6);

        // 구매마감시간후 에러테스트
        vm.warp(purchaseEndTimestamp + 1);
        // console.log(vesting.returnTokenAmount(address(dongToken)));
        vm.expectRevert("purchase time end");
        vesting.tokenPurchase(address(dongToken), 1e6);

        vm.stopPrank();
    }

    function testClaimToken() public {
        vm.startPrank(owner);
        dongToken.mint(owner, 1000e6);
        dongToken.approve(address(vesting), 10000e18);
        vesting.depositToken(
            address(dongToken), 10000e18, tokenPrice, lockTimestamp, vestingEndTimestamp, purchaseEndTimestamp
        );

        vm.stopPrank();
        vm.startPrank(me);
        IERC20(address(usdc)).approve(address(vesting), 10000e6);
        vesting.tokenPurchase(address(dongToken), 100e6);
        // console.log(vesting.returnUnclaimToken(address(dongToken), me));

        // 락타임전 테스트
        vm.warp(lockTimestamp - 1);
        vm.expectRevert("not yet");
        vesting.claimToken(address(dongToken));

        vm.warp(vestingEndTimestamp - 29184000);
        vesting.claimToken(address(dongToken));
        console.log(IERC20(address(dongToken)).balanceOf(me));

        vm.warp(vestingEndTimestamp);
        vesting.claimToken(address(dongToken));
        assertEq(1000e18, IERC20(address(dongToken)).balanceOf(me));
    }

    function testWithdraUsdc() public {
        vm.startPrank(owner);
        dongToken.mint(owner, 1000e6);
        dongToken.approve(address(vesting), 10000e18);
        vesting.depositToken(
            address(dongToken), 10000e18, tokenPrice, lockTimestamp, vestingEndTimestamp, purchaseEndTimestamp
        );

        vm.stopPrank();
        vm.startPrank(me);
        IERC20(address(usdc)).approve(address(vesting), 10000e6);
        vesting.tokenPurchase(address(dongToken), 100e6);

        vm.expectRevert("not owner");
        vesting.withdrawUsdc(address(dongToken));

        vm.stopPrank();
        vm.prank(owner);
        vesting.withdrawUsdc(address(dongToken));
        assertEq(IERC20(usdc).balanceOf(owner), 1100e6);
    }
}
