// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract BasicBank {

    mapping(address => uint256) balance;

    /// @notice deposit ether into the contract
    /// @dev it should work properly when called multiple times
    function addEther() external payable {
        address(this).call{value:msg.value}("");
        balance[msg.sender] += msg.value;

    }

    /// @notice used to withdraw ether from the contract (No restriction on withdrawals)
    function removeEther(uint256 amount) external payable {
        require(balance[msg.sender]>=amount,"");
        msg.sender.call{value:amount}("");
    }

    // receive() external payable{

    // }
}
