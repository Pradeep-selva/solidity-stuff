const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Auction", function () {
  it("Should create auction successfully with correct itemName and manager", async function () {
    const auctionDetails = {
      itemName: "TestItem",
      duration: 30
    };

    const [auctionManager] = await ethers.getSigners();

    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy();
    await auction.deployed();

    const createAuctionTx = await auction.createExhibit(
      auctionDetails.itemName,
      auctionDetails.duration
    );
    await createAuctionTx.wait();

    const fetchedAuctionDetails = await auction.getAuctionDetails(0);

    expect(fetchedAuctionDetails[1]).to.equal(auctionDetails.itemName);
    expect(fetchedAuctionDetails[0]).to.equal(auctionManager.address);
  });
});
