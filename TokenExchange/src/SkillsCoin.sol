// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

// 두 개의 ERC20 계약을 작성하세요: RareCoin과 SkillsCoin(원하는 경우 이름을 변경할 수 있습니다). 
// 누구나 스킬코인을 발행할 수 있지만, RareCoin을 얻는 유일한 방법은 스킬코인을 RareCoin 계약으로 보내는 것뿐입니다. 
// 소유자만 스킬코인을 발행할 수 있다는 제한을 제거해야 합니다.
contract SkillsCoin {

    

    string public name;
    string public symbol;

    mapping(address => uint256) public _balanceOf;
    address public owner;
    uint8 public decimals;

    uint256 public totalSupply;

    // owner -> spender -> allowance
    // this enables an owner to give allowance to multiple addresses
    mapping(address => mapping(address => uint256)) public allowance;

        constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;

        owner = msg.sender;
    }


    function mint(uint256 amount) public {
        
        totalSupply += amount;
        _balanceOf[msg.sender] += amount;
    }

    function approve(address rareCoinAddress, uint256 amount) public returns (bool){
        allowance[msg.sender][rareCoinAddress] = amount;
        
        return true;
    }

    function transferFrom(address from, address to,uint256 amount ) public returns (bool){
        require(allowance[from][to] >= amount,"fail SkillsCoin contract trasferForm");
        allowance[from][to] -= amount;

        return helperTransfer(from, to, amount);
    }

    function transfer(address from, address to, uint256 amount) public returns(bool) {
        return helperTransfer(from, to, amount);
    }

    // it's very important for this function to be internal!
    function helperTransfer(address from, address   to, uint256 amount) internal returns (bool) {
        require(_balanceOf[from] >= amount, "not enough money");
        require(to != address(0), "cannot send to address(0)");
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;

        return true;
    }
    function balanceOf(address _address) public view returns (uint256){
        return _balanceOf[_address];
    }
 
}