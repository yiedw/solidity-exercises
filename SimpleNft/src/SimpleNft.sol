
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;


contract SimpleNft{
    
    mapping(uint256 => address) public _owners;

    string baseURL = "http://api.coolcatsnft.com/cat/";

    function mint(uint256 _tokenId) external {
        require(_owners[_tokenId] == address(0) , "Already minted");
        require(_tokenId < 100, "_tokenId too Large" );
        _owners[_tokenId] = msg.sender;
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        require(_owners[_tokenId] != address(0),"No such token");
        return _owners[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_owners[_tokenId] == _from ,"not nft owner");
        require(msg.sender == _from, "sender is not owner");

        _owners[_tokenId] = _to;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory){
        require(_owners[_tokenId] != address(0));
        return string(abi.encodePacked(baseURL,_tokenId.toString()));
    }

}