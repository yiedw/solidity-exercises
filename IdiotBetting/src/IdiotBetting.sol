// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract IdiotBettingGame {
    /*
        This exercise assumes you know how block.timestamp works.
        - Whoever deposits the most ether into a contract wins all the ether if no-one 
          else deposits after an hour.
        1. `bet` function allows users to deposit ether into the contract. 
           If the deposit is higher than the previous highest deposit, the endTime is 
           updated by current time + 1 hour, the highest deposit and winner are updated.
        2. `claimPrize` function can only be called by the winner after the betting 
           period has ended. It transfers the entire balance of the contract to the winner.
    */

    uint256 highestValue = 0;
    address highestAddress;
    uint256 lastTime;

    function bet() public payable {
        // your code here
        if (msg.value > highestValue) {
            highestValue = msg.value;
            highestAddress = msg.sender;
            lastTime = block.timestamp;
        }
    }

    function claimPrize() public {
        // your code here
        require(msg.sender == highestAddress);
        require(block.timestamp >= lastTime + 1 hours);
        highestAddress.call{value: address(this).balance}("");
    }
    function time()public view returns(uint256){
        return lastTime;
    }
}
