// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract OneWeekLockup {
    /**
     * In this exercise you are expected to create functions that let users deposit ether
     * Users can also withdraw their ether (not more than their deposit) but should only be able to do a week after their last deposit
     * Consider edge cases by which users might utilize to deposit ether
     *
     * Required function
     * - depositEther()
     * - withdrawEther(uint256 )
     * - balanceOf(address )
     */
    
    mapping(address => uint256) balances;
    mapping(address => uint256) lastDeposits;

    function balanceOf(address user) public view returns (uint256) {
        // return the user's balance in the contract
        return balances[user];
    }

    function lastDepositsTime(address user) public view returns(uint256){
        return lastDeposits[user];
    }

    function depositEther() external payable {
        /// add code here
        balances[msg.sender] += msg.value;
        lastDeposits[msg.sender] = block.timestamp;

    }

    function withdrawEther(uint256 amount) external {
        /// add code here
        require(balances[msg.sender]>=amount,"amount fail");
        require(block.timestamp >= lastDeposits[msg.sender] + 1 weeks ,"time fail");
        balances[msg.sender] -= amount;
        msg.sender.call{value:amount}("");
    }

    // receive() external payable{

    // }
}
