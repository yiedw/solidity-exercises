// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract Withdraw {
    // @notice make this contract able to receive ether from anyone and anyone can call withdraw below to withdraw all ether from it

    mapping(address => uint256) balance;
    function withdraw() public {
        // your code here
        msg.sender.call{value:balance[msg.sender]}("");
        balance[msg.sender] =0;

    }

    receive() external payable{

        balance[msg.sender] += msg.value;
    }
}

