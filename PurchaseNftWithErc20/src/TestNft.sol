// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TestNft is ERC721("Nft", "nft") {
    string private _name;
    string private _symbol;
    address private _owner;

    uint256 private _tokenId = 0;

    // USDC contract address on mainnet
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 100;
    mapping(uint256 => uint256) public balance;

    uint256 price = 1e6;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }

    // mint for usdc
    function mint() external payable {
        // Max Supply check
        require(tokenSupply < MAX_SUPPLY, "minting end");

        // usdc balance check
        require(IERC20(usdc).balanceOf(msg.sender) >= price, "lack of usdc");

        // approve check
        require(IERC20(usdc).allowance(msg.sender, address(this)) >= price, "approve first");

        // usdc transfer (msg.sender -> nft contract)
        bool _ok = IERC20(usdc).transferFrom(msg.sender, address(this), price);
        require(_ok, "usdc ransferfrom fail");

        _mint(msg.sender, _tokenId);
        balance[_tokenId]++;

        tokenSupply++;
        _tokenId++;
    }

    function withdrawUsdc(uint256 amount) public {
        // contract owner check
        require(msg.sender == _owner, "not contract owner");

        // balance check
        require(IERC20(usdc).balanceOf(address(this)) >= amount, "lack of balance");

        bool _ok = IERC20(usdc).transfer(_owner, amount);
        require(_ok, "usdc withdraw fail");
    }

    function currentTokenSupply() public view returns (uint256) {
        return tokenSupply;
    }

    function currentContractOwner() public view returns (address) {
        return _owner;
    }
}
