// SPDX-License-Identifier: MIT
pragma solidity  >=0.7.6;

import "./Types.sol";

contract Auction {
    uint256 private constant  BLOCK_TIME = 15;
    mapping(uint256 => Types.Exhibit) private exhibits;
    uint256 public totalExhibits;
    
    event Created(address indexed manager, uint256 indexed exhibitIndex, uint256 endTime);
    event NewBid(address indexed bidder, uint256 indexed exhibitIndex, uint256 bidAmount);
    event Withdrawn(address indexed manager, uint256 indexed exhibitIndex, uint256 bidAmount);
    
    constructor() {
        totalExhibits = 0;
    }
    
    function createExhibit(string memory itemName, uint256 duration) external validUser {
        Types.Exhibit storage exhibit = exhibits[totalExhibits++];
        
        exhibit.manager = payable(msg.sender);
        exhibit.duration = ((duration/BLOCK_TIME) + block.number) * BLOCK_TIME;
        exhibit.itemName= itemName;
        exhibit.bidAmount = 0;
        
        emit Created(msg.sender, totalExhibits-1, duration);
    }
    
    function bid(uint256 exhibitIndex) external payable highestBid(exhibitIndex) running(exhibitIndex) bidder(exhibitIndex) validUser {
        Types.Exhibit storage exhibit = exhibits[exhibitIndex];
        
        uint256 transferAmount = exhibit.bidAmount;
        address payable previousBidder = exhibit.winner;
        
        exhibit.bidAmount = msg.value;
        exhibit.winner = payable(msg.sender); 
        
        emit NewBid(msg.sender, exhibitIndex, msg.value);

        previousBidder.transfer(transferAmount);
    }
    
    function withdraw(uint256 exhibitIndex) external manager(exhibitIndex) complete(exhibitIndex) validUser {
        Types.Exhibit memory exhibit = exhibits[exhibitIndex];
        emit Withdrawn(exhibit.manager, exhibitIndex, exhibit.bidAmount);
        
        exhibit.manager.transfer(exhibit.bidAmount);
    }
    
    function getAuctionDetails(uint256 exhibitIndex) external view validUser returns (
            address,
            string memory,
            uint256,
            address,
            uint256,
            bool
    ) {
        address winner = address(0x0);
        bool hasEnded = false;
        Types.Exhibit memory exhibit = exhibits[exhibitIndex];

        if(getDurationElapsed() > exhibit.duration) {
            winner = exhibit.winner;
            hasEnded = true;
        }
        
        return (
            exhibit.manager,
            exhibit.itemName,
            exhibit.bidAmount,
            winner,
            exhibit.duration,
            hasEnded
        );
    }
    
    function getDurationElapsed() internal view returns (uint256) {
        return block.number * BLOCK_TIME;
    }
    
    modifier highestBid(uint256 index) {
        require(msg.value > exhibits[index].bidAmount, "You must bid higher than the previous one.");
        _;
    }
    
    modifier running(uint256 index) {
        require(getDurationElapsed() <= exhibits[index].duration, "This exhibit has ended already.");
        _;
    }
    
    modifier complete(uint256 index) {
        require(getDurationElapsed() > exhibits[index].duration, "This exhibit hasn't ended yet. Please wait.");
        _;
    }
    
    modifier manager(uint256 index) {
        require(msg.sender == exhibits[index].manager, "You aren't the manager so you cannot withdraw.");
        _;
    }
    
    modifier bidder(uint256 index) {
        require(msg.sender != exhibits[index].manager, "You aren't the manager so you cannot withdraw.");
        _;
    }
    
    modifier validUser() {
        require(msg.sender == tx.origin, "Smart contracts cannot call this function.");
        _;
    }
}
