// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNft is ERC721("Nft", "nft") {
    string private _name;
    string private _symbol;

    uint256 private _tokenId = 0;
    mapping(uint256 => address) private nftOwner;

    uint256 public tokenSupply = 0;
    uint256 public constant MAX_SUPPLY = 100;
    mapping(uint256 => uint256) public balance;

    uint256 price = 1_000_000_000_000_000_000;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // Erc20으로 민팅
    function mint(address usdcAddress, address _to) external payable {
        // usdc 컨트랙트가 맞는지 확인
        // USDC contract address on mainnet
        require(usdcAddress == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        require(tokenSupply < MAX_SUPPLY);
        (bool _ok,) = usdcAddress.call(
            abi.encodeWithSignature("transferfrom(address,address,uint265)", msg.sender, address(this), price)
        );

        require(_ok);
        _mint(_to, _tokenId);
        nftOwner[_tokenId] = _to;
        balance[_tokenId]++;

        price += 1_000_000_000_000_000_000;
        tokenSupply++;
        _tokenId++;
    }
}
