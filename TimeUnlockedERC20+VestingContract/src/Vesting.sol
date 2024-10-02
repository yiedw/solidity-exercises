// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

// Store ERC20 tokens in a vesting contract for sale
// Buyers purchase the ERC20 tokens
// Buyers can claim the ERC20 tokens after a specific period (lockup or vesting)

contract Vesting {
    // 나중에 추가할것 : 화이트리스트
    address private _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    struct AmountInfo {
        uint256 totalAmount;
        uint256 claimAmount;
    }

    struct TokenInfo {
        uint256 tokenSupply;
        uint256 restToken;
        uint256 claimToken;
        uint256 lockTimestamp;
        uint256 vestingEndTimestamp;
        uint256 purchaseEndTimestamp;
        uint256 usdcAmount;
        address salesOwner;
    }

    mapping(address => mapping(address => AmountInfo)) amountInfo;
    mapping(address => TokenInfo) tokenInfo;

    constructor() {}

    function tokenPurchase(address tokenAddress, uint256 usdcAmount, uint256 rate) public {
        uint256 purchaseAmount = usdcAmount * rate;

        // usdc check
        require(IERC20(_usdc).balanceOf(msg.sender) >= usdcAmount, "lack of usdc");
        // restToken check
        require(tokenInfo[tokenAddress].restToken >= purchaseAmount, "lack of restToken");
        // usdc transferfrom
        require(IERC20(_usdc).transferFrom(msg.sender, address(this), usdcAmount), "usdc transferFrom fail");
        // token mint
        // ex) 1 dong = 10 usdc
        // (bool ok,) =
        //     address(tokenAddress).call(abi.encodeWithSignature("mint(address,uint256)", address(this), usdcAmount));
        // require(ok, "token mint fail");

        // AmountInfo amountInfo=AmountInfo(usdcAmount*rate,usdcAmount*rate,0,block.timestamp);
        amountInfo[tokenAddress][msg.sender] = AmountInfo(purchaseAmount, 0);
        tokenInfo[tokenAddress].usdcAmount += usdcAmount;
        tokenInfo[tokenAddress].restToken -= purchaseAmount;
    }

    function claimToken(address tokenAddress) public {
        // purchase time check
        require(block.timestamp < tokenInfo[tokenAddress].purchaseEndTimestamp, "purchase time end");
        // lock check
        require(block.timestamp >= tokenInfo[tokenAddress].lockTimestamp, "not yet");

        uint256 totalVestingDay = tokenInfo[tokenAddress].vestingEndTimestamp - tokenInfo[tokenAddress].lockTimestamp;
        uint256 lastClaimDay = block.timestamp - tokenInfo[tokenAddress].lockTimestamp / 1 days;
        uint256 restAmount = (amountInfo[tokenAddress][msg.sender].totalAmount / totalVestingDay) * lastClaimDay
            - amountInfo[tokenAddress][msg.sender].claimAmount;

        bool ok = IERC20(tokenAddress).transferFrom(address(this), msg.sender, restAmount);
        require(ok, "token transferFrom fail");
        amountInfo[tokenAddress][msg.sender].claimAmount += restAmount;
    }

    // token deposit
    function depositToken(
        address tokenAddress,
        uint256 tokenSupply,
        uint256 lockTimestamp,
        uint256 vestingEndTimestamp,
        uint256 purchaseEndTimestamp
    ) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenSupply);
        tokenInfo[tokenAddress].tokenSupply = tokenSupply;
        tokenInfo[tokenAddress].lockTimestamp = lockTimestamp;
        tokenInfo[tokenAddress].vestingEndTimestamp = vestingEndTimestamp;
        tokenInfo[tokenAddress].purchaseEndTimestamp = purchaseEndTimestamp;
        tokenInfo[tokenAddress].salesOwner = msg.sender;
    }

    // usdc withdraw
    function withdrawUsdc(address tokenAddress) public {
        require(msg.sender == tokenInfo[tokenAddress].salesOwner, "not owner");

        bool ok = IERC20(_usdc).transferFrom(address(this), msg.sender, tokenInfo[tokenAddress].usdcAmount);
        require(ok, "usdc transferFrom fail");
    }
}
