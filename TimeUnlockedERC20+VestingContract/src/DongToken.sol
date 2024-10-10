// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract DongToken is ERC20("DONG", "dong") {
    uint256 MAX_SUPPLY = 100000e18;

    address private _owner;
    // uint256 private _totalSupply = 0;

    string private _name;
    string private _symbol;

    mapping(address => bool) _whitelists;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }

    // purchase for usdc
    // receive 1 year vesting

    // USDC contract address on mainnet
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // owner or whitelist address(vesting contract)
    function mint(address to, uint256 usdcAmount) public {
        require(_owner == msg.sender || _whitelists[msg.sender], "not owner");
        // 10 dt = 1 usdc
        _mint(to, usdcAmount * 1e12 * 10);
    }

    function addWhitelist(address whitelistAddress) public {
        _whitelists[whitelistAddress] = true;
    }
}
