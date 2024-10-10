// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

// Store ERC20 tokens in a vesting contract for sale
// Buyers purchase the ERC20 tokens
// Buyers can claim the ERC20 tokens after a specific period (lockup or vesting)

contract Vesting {
    address private _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private _owner;

    struct AmountInfo {
        uint256 totalAmount;
        uint256 claimedAmount;
    }

    struct TokenInfo {
        uint256 tokenAmount;
        uint256 claimToken;
        uint256 lockTimestamp;
        uint256 vestingEndTimestamp;
        uint256 purchaseEndTimestamp;
        uint256 usdcAmount;
        uint256 tokenPrice;
        address salesOwner;
    }

    mapping(address => mapping(address => AmountInfo)) amountInfo;
    mapping(address => TokenInfo) tokenInfo;

    constructor() {
        _owner = msg.sender;
    }

    function tokenPurchase(address tokenAddress, uint256 usdcAmount) public {
        uint256 purchaseAmount = usdcAmount * tokenInfo[tokenAddress].tokenPrice * 1e12;

        // restToken check
        require(tokenInfo[tokenAddress].tokenAmount >= purchaseAmount, "lack of token");
        // usdc transferfrom
        require(IERC20(_usdc).transferFrom(msg.sender, address(this), usdcAmount), "usdc transferFrom fail");
        // purchase time check
        require(block.timestamp < tokenInfo[tokenAddress].purchaseEndTimestamp, "purchase time end");

        // token mint
        // ex) 1 dong = 10 usdc
        // (bool ok,) =
        //     address(tokenAddress).call(abi.encodeWithSignature("mint(address,uint256)", address(this), usdcAmount));
        // require(ok, "token mint fail");

        // AmountInfo amountInfo=AmountInfo(usdcAmount*rate,usdcAmount*rate,0,block.timestamp);
        amountInfo[tokenAddress][msg.sender].totalAmount += purchaseAmount;
        tokenInfo[tokenAddress].usdcAmount += usdcAmount;
        tokenInfo[tokenAddress].tokenAmount -= purchaseAmount;
    }

    function claimToken(address tokenAddress) public {
        // lock check
        require(block.timestamp >= tokenInfo[tokenAddress].lockTimestamp, "not yet");

        // uint256 totalVestingDay = tokenInfo[tokenAddress].vestingEndTimestamp - tokenInfo[tokenAddress].lockTimestamp;
        // uint256 lastClaimDay = block.timestamp - tokenInfo[tokenAddress].lockTimestamp / 1 days;
        uint256 claimableAmount;
        if (block.timestamp >= tokenInfo[tokenAddress].vestingEndTimestamp) {
            claimableAmount =
                amountInfo[tokenAddress][msg.sender].totalAmount - amountInfo[tokenAddress][msg.sender].claimedAmount;
        } else {
            claimableAmount = amountInfo[tokenAddress][msg.sender].totalAmount
                * (block.timestamp - tokenInfo[tokenAddress].lockTimestamp)
                / (tokenInfo[tokenAddress].vestingEndTimestamp - tokenInfo[tokenAddress].lockTimestamp);
        }

        bool ok = IERC20(tokenAddress).transfer(msg.sender, claimableAmount);
        require(ok, "token transfer fail");
        amountInfo[tokenAddress][msg.sender].claimedAmount += claimableAmount;
    }

    // token deposit
    function depositToken(
        address tokenAddress,
        uint256 tokenAmount,
        uint256 tokenPrice,
        uint256 lockTimestamp,
        uint256 vestingEndTimestamp,
        uint256 purchaseEndTimestamp
    ) public {
        require(msg.sender == _owner, "not owner!");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount);
        tokenInfo[tokenAddress].tokenAmount = tokenAmount;
        tokenInfo[tokenAddress].tokenPrice = tokenPrice;
        tokenInfo[tokenAddress].lockTimestamp = lockTimestamp;
        tokenInfo[tokenAddress].vestingEndTimestamp = vestingEndTimestamp;
        tokenInfo[tokenAddress].purchaseEndTimestamp = purchaseEndTimestamp;
        tokenInfo[tokenAddress].salesOwner = msg.sender;
    }

    // usdc withdraw
    function withdrawUsdc(address tokenAddress) public {
        require(msg.sender == tokenInfo[tokenAddress].salesOwner, "not owner");
        bool ok = IERC20(_usdc).transfer(msg.sender, tokenInfo[tokenAddress].usdcAmount);
        require(ok, "usdc transferFrom fail");
        tokenInfo[tokenAddress].usdcAmount = 0;
    }

    function returnUnclaimToken(address tokenAddress, address purhcaseAddress) public view returns (uint256) {
        return
            amountInfo[tokenAddress][purhcaseAddress].totalAmount - amountInfo[tokenAddress][msg.sender].claimedAmount;
    }

    function returnTokenAmount(address tokenAddress) public view returns (uint256) {
        return tokenInfo[tokenAddress].tokenAmount;
    }
}
