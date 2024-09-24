// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleNft {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(uint256 => address) private _owners;
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => uint256) _balances;

    string baseURL = "http://api.coolcatsnft.com/cat/";

    function mint(uint256 _tokenId) external {
        require(_owners[_tokenId] == address(0), "Already minted");
        require(_tokenId < 100, "_tokenId too Large");

        emit Transfer(address(0), msg.sender, _tokenId);
        _balances[msg.sender]++;
        _owners[_tokenId] = msg.sender;
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(_owners[_tokenId] != address(0), "No such token");
        return _owners[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_owners[_tokenId] == _from, "not nft owner");
        require(msg.sender == _from || _operators[_from][msg.sender], "sender is not owner");

        emit Transfer(_from, _to, _tokenId);
        _balances[_from]--;
        _balances[_to]++;
        _operators[_from][msg.sender] = false;
        _owners[_tokenId] = _to;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_owners[_tokenId] != address(0));
        return string(abi.encodePacked(baseURL, Strings.toString(_tokenId)));
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        // for(_operators[_msg.sender])
        emit ApprovalForAll(msg.sender, _operator, _approved);
        _operators[msg.sender][_operator] = _approved;
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _operators[_owner][_operator];
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return _balances[_owner];
    }
}
