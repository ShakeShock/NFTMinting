const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Shaker Mint", function () {
  const freeSupply = 10;
  let shaker;

  beforeEach(async function () {
    const Shaker = await ethers.getContractFactory("Shaker");
    shaker = await Shaker.deploy(
      [0, 1, 2],
      [0, 0, 0],
      [0, 0, 0],
      ["l1", "l2", "l3"],
      freeSupply
    );
  });

  it("Should store correctly all links", async function () {
    const shakerMetadataTx0 = await shaker.getShakerMetadataLink(0, 0, 0);
    const shakerMetadataTx1 = await shaker.getShakerMetadataLink(1, 0, 0);
    const shakerMetadataTx2 = await shaker.getShakerMetadataLink(2, 0, 0);

    expect(shakerMetadataTx0).to.equal("l1");
    expect(shakerMetadataTx1).to.equal("l2");
    expect(shakerMetadataTx2).to.equal("l3");
  });

  it("Should mint a character only once", async function () {
    [owner, signer1, ...addrs] = await ethers.getSigners();
    await shaker.connect(signer1).mintShaker(1);

    await expect(shaker.connect(signer1).mintShaker(1)).to.be.revertedWith(
      "Already owns maximum number of shakers"
    );
  });

  it("Should have limited free minting", async function () {
    [owner, signer1, signer2, ...addrs] = await ethers.getSigners();

    await shaker.connect(signer1).mintShaker(3);
    await expect(shaker.connect(signer2).mintShaker(3)).to.be.revertedWith(
      "No more type three free"
    );

    await expect(
      shaker
        .connect(signer2)
        .mintShaker(3, { value: ethers.utils.parseEther("0.015") })
    ).to.be.revertedWith("Insuficient funds");

    shaker
      .connect(signer2)
      .mintShaker(3, { value: ethers.utils.parseEther("0.06") });
  });
});
