// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction {

    address payable public beneficiary;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturns;
    bool ended = false;

    event HighestBidIncrease(address bidder, uint amount);
    event auctionEnded(address winner,uint amount);

    constructor(uint _biddingtime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingtime;
    }
    function bid()public payable{
        if(block.timestamp >= auctionEndTime){
            revert("the auction has already ended");
        }
        if(msg.value <= highestBid){
            revert("There is already a higher or equal Bid");
        }
        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender,msg.value);

    }
    function withdraw() public returns (bool){
        uint _amount = pendingReturns[msg.sender];
        if(_amount > 0){
            pendingReturns[msg.sender] = 0;

          if(!payable(msg.sender).send(_amount)){
              pendingReturns[msg.sender] = _amount;
              return false;
            }
        }
        return true;
    }
    function auctionEnd() public {
        if(block.timestamp < auctionEndTime){
            revert("The Auction has not ended yet");
        }
        if(ended){
            revert("The function auction ended has already been called");
        }
        ended = true;
        emit auctionEnded(highestBidder,highestBid);

        beneficiary.transfer(highestBid);
    }

}
