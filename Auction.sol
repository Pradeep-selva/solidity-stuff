// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./Types.sol";

contract Auction {
    mapping(uint256 => Types.Exhibit) private exhibits;
    uint256 public totalExhibits;
    
    event Created(address indexed manager, uint256 indexed exhibitIndex, uint256 endTime);
    event NewBid(address indexed bidder, uint256 indexed exhibitIndex, uint256 bidAmount);
    event Withdrawn(address indexed manager, uint256 indexed exhibitIndex, uint256 bidAmount);
    
    constructor() {
        totalExhibits = 0;
    }
    
    function createExhibit(string memory itemName, uint256 endTime) public validUser {
        Types.Exhibit storage exhibit = exhibits[totalExhibits++];
        
        exhibit.manager = payable(msg.sender);
        exhibit.endTime = endTime;
        exhibit.itemName= itemName;
        exhibit.bidAmount = 0;
        
        emit Created(msg.sender, totalExhibits-1, endTime);
    }
    
    function bid(uint256 exhibitIndex) public payable highestBid(exhibitIndex) running(exhibitIndex) bidder(exhibitIndex) validUser {
        Types.Exhibit storage exhibit = exhibits[exhibitIndex];
        
        exhibit.winner.transfer(exhibit.bidAmount);
        
        exhibit.bidAmount = msg.value;
        exhibit.winner = payable(msg.sender); 
        
        emit NewBid(msg.sender, exhibitIndex, msg.value);
    }
    
    function withdraw(uint256 exhibitIndex) public manager(exhibitIndex) complete(exhibitIndex) validUser {
        Types.Exhibit memory exhibit = exhibits[exhibitIndex];
        exhibit.manager.transfer(exhibit.bidAmount);
        
        emit Withdrawn(exhibit.manager, exhibitIndex, exhibit.bidAmount);
    }
    
    function getAuctionDetails(uint256 exhibitIndex) public view validUser returns (
            address,
            string memory,
            uint256,
            address,
            bool
    ) {
        address winner = address(0x0);
        bool hasEnded = false;
        Types.Exhibit memory exhibit = exhibits[exhibitIndex];

        if(block.timestamp > exhibit.endTime) {
            winner = exhibit.winner;
            hasEnded = true;
        }
        
        return (
            exhibit.manager,
            exhibit.itemName,
            exhibit.bidAmount,
            winner,
            hasEnded
        );
    }
    
    modifier highestBid(uint256 index) {
        require(msg.value > exhibits[index].bidAmount, "You must bid higher than the previous one.");
        _;
    }
    
    modifier running(uint256 index) {
        require(block.timestamp <= exhibits[index].endTime, "This exhibit has ended already.");
        _;
    }
    
    modifier complete(uint256 index) {
        require(block.timestamp > exhibits[index].endTime, "This exhibit hasn't ended yet. Please wait.");
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
