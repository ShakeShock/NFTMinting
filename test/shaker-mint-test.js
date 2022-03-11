const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Shaker Mint", function () {
  const freeSupply = 10;
  let shaker;
  let stringTools;

  before(async function () {
    const StringTools = await ethers.getContractFactory("StringTools");
    stringTools = await StringTools.deploy();
  });

  beforeEach(async function () {
    const Shaker = await ethers.getContractFactory("Shaker", {
      libraries: { StringTools: stringTools.address },
    });
    shaker = await Shaker.deploy(
      [0, 1, 2],
      [0, 0, 0],
      [0, 0, 0],
      ["l1", "l2", "l3"],
      [
        { amount: 7, price: ethers.utils.parseEther("0") },
        { amount: 2, price: ethers.utils.parseEther("0.03") },
        { amount: 1, price: ethers.utils.parseEther("0.06") },
      ]
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
    await shaker.connect(signer1).mintShaker(0);

    await expect(shaker.connect(signer1).mintShaker(0)).to.be.revertedWith(
      "Address has already maximum number of shakers"
    );
  });

  it("Should have limited minting", async function () {
    [owner, signer1, signer2, ...addrs] = await ethers.getSigners();

    await shaker
      .connect(signer1)
      .mintShaker(2, { value: ethers.utils.parseEther("0.06") });
    await expect(shaker.connect(signer2).mintShaker(2)).to.be.revertedWith(
      "No more minting for type selected"
    );

    await expect(
      shaker
        .connect(signer2)
        .mintShaker(1, { value: ethers.utils.parseEther("0.015") })
    ).to.be.revertedWith("Insuficient funds");

    await expect(shaker.connect(signer2).mintShaker(100)).to.be.revertedWith(
      "Invalid shaker type"
    );

    shaker
      .connect(signer2)
      .mintShaker(1, { value: ethers.utils.parseEther("0.03") });
  });
});
