// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract TimelockEscrow {
    address public seller;
    mapping(address => uint256) public buyTimes;
    mapping(address => uint256) public buyPrices;

    /**
     * The goal of this exercise is to create a Time lock escrow.
     * A buyer deposits ether into a contract, and the seller cannot withdraw it until 3 days passes. Before that, the buyer can take it back
     * Assume the owner is the seller
     */

    constructor() {
        seller = msg.sender;
    }

        function buyerTime(address buyer) public view returns (uint256){
        return buyTimes[buyer];
    }

    // creates a buy order between msg.sender and seller
    /**
     * escrows msg.value for 3 days which buyer can withdraw at anytime before 3 days but afterwhich only seller can withdraw
     * should revert if an active escrow still exist or last escrow hasn't been withdrawn
     */
    function createBuyOrder() external payable {
        // your code here
        buyTimes[msg.sender] = block.timestamp;
        buyPrices[msg.sender] = msg.value;
    }

    /**
     * allows seller to withdraw after 3 days of the escrow with @param buyer has passed
     */
    function sellerWithdraw(address buyer) external {
        // your code here
        require(block.timestamp > buyTimes[buyer] + 3 days,"1");
        require(seller == msg.sender,"2");
        seller.call{value:buyPrices[buyer]}("");
        buyPrices[buyer] = 0;
    }

    /**
     * allowa buyer to withdraw at anytime before the end of the escrow (3 days)
     */
    function buyerWithdraw() external {
        // your code here
        require(block.timestamp <= buyTimes[msg.sender] + 3 days);
        msg.sender.call{value:buyPrices[msg.sender]}("");
        buyPrices[msg.sender] = 0;
        
    }

    // returns the escrowed amount of @param buyer
    function buyerDeposit(address buyer) external view returns (uint256) {
     return buyPrices[buyer];   
    }
}
