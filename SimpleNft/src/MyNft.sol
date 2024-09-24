// https://testnets.opensea.io/collection/dong-5

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNft is ERC721, Ownable {
    uint256 public constant MAX_SUPPLY = 3;
    uint256 public tokenSupply = 0;
    uint256 public price = 0.001 ether;

    address immutable deployer;

    constructor() ERC721("DONG", "DD") Ownable(msg.sender) {
        deployer = msg.sender;
    }

    function mint() external payable {
        require(tokenSupply < MAX_SUPPLY, "supply used up");
        require(msg.value == price, "wrong price");
        _mint(msg.sender, tokenSupply);
        tokenSupply++;
        price += 0.001 ether;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://QmfDQTWKnN239opjfG211fqvHqSaYAqEgMKuoqeCG2os7X/";
    }
}
