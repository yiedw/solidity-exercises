// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

// 두 개의 ERC20 계약을 작성하세요: RareCoin과 SkillsCoin(원하는 경우 이름을 변경할 수 있습니다). 
// 누구나 스킬코인을 발행할 수 있지만, RareCoin을 얻는 유일한 방법은 스킬코인을 RareCoin 계약으로 보내는 것뿐입니다. 
// 소유자만 스킬코인을 발행할 수 있다는 제한을 제거해야 합니다.

contract RareCoin {

    string public name;
    string public symbol;

    mapping(address => uint256) public _balanceOf;
    address public owner;
    uint8 public decimals;

    uint256 public totalSupply;

        constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;

        owner = msg.sender;
    }


    function mint(address to,uint256 amount) private {
        // require(msg.sender==address(this),"from != this contract");
        totalSupply += amount;
        _balanceOf[to] += amount;
    }

    function trade(address skillsCoinAddress, uint256 amount) public returns(bool){
        (bool ok, bytes memory _result )=skillsCoinAddress.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender,address(this),amount));
        require(ok);
        bool result = abi.decode(_result,(bool));
        require(result, "fail skillsCoinAddress.transferFrom()");
        mint(msg.sender, amount);
        return true;
    }

    function balanceOf(address _address) public view returns(uint256){
        return _balanceOf[_address];
    }
}