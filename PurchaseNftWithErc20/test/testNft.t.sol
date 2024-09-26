// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TestNft} from "../src/TestNft.sol";
import "forge-std/interfaces/IERC20.sol";

// interface IUSDC {
//     function balanceOf(address account) external view returns (uint256);
//     function mint(address to, uint256 amount) external;
//     function configureMinter(address minter, uint256 minterAllowedAmount) external;
//     function masterMinter() external view returns (address);
// }

contract NftTest is Test {
    // USDC contract address on mainnet
    TestNft private _testNft;

    // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // addr = 0xD8da6BF26964AF937eed9E03e53415d37AA96044;

    address internal me = makeAddr("me");

    function setUp() public {
        deal(usdc, me, 1e6);
        _testNft = new TestNft("NFT", "nft");
        // console.log(IERC20(usdc).balanceOf(me));
        // console.log(usdc.balanceOf(me));
    }

    function testMint() public {
        // console.log(address(me));
        // console.log(address(this));

        // success
        vm.startPrank(me);
        IERC20(usdc).approve(address(_testNft), 1e6);
        _testNft.mint();
        assertEq(_testNft.ownerOf(0), address(me));

        // laco of usdc
        vm.expectRevert("lack of usdc");
        _testNft.mint();

        // not approve
        deal(usdc, me, 1e6);
        vm.expectRevert("approve first");
        _testNft.mint();

        // max supply exceed
        deal(usdc, me, 99e6);
        IERC20(usdc).approve(address(_testNft), 1000e6);
        // console.log(IERC20(usdc).allowance(me, address(_testNft)));
        for (uint256 i = 0; i < 99; i++) {
            _testNft.mint();
            // console.log(_testNft.currentTokenSupply());
        }
        vm.expectRevert("minting end");
        _testNft.mint();
    }

    function testWithdrawUsdc() public {
        deal(usdc, me, 1e6);
        vm.startPrank(me);
        IERC20(usdc).approve(address(_testNft), 1000e6);
        _testNft.mint();

        // not contract owner
        vm.expectRevert("not contract owner");
        _testNft.withdrawUsdc(100e6);

        vm.stopPrank();

        // amount > balance
        vm.expectRevert("lack of balance");
        _testNft.withdrawUsdc(1000e6);

        //success
        _testNft.withdrawUsdc(1e6);
        assertEq(IERC20(usdc).balanceOf(address(this)), 1e6);
    }
}
