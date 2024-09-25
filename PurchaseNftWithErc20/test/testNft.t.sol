// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {TestNft} from "../src/TestNft.sol";

interface IUSDC {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
}

contract TestNftTest is Test {
    // USDC contract address on mainnet
    IUSDC usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    console.log("aa");

    address internal me = makeAddr("me");
    address internal noMoney = makeAddr("noMoney");

    function setUp() public {
        usdc.mint(me, 1000e18);
    }

    
}
