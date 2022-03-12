const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Gear Mint", function () {
  let gear;
  let stringTools;

  before(async function () {
    const StringTools = await ethers.getContractFactory("StringTools");
    stringTools = await StringTools.deploy();
  });

  beforeEach(async function () {
    const amount = [5, 2, 1];
    const price = [
      ethers.utils.parseEther("0.0"),
      ethers.utils.parseEther("0.015"),
      ethers.utils.parseEther("0.03"),
    ];
    const uris = ["l1", "l2", "l3"];

    const Gear = await ethers.getContractFactory("DefensiveGear", {
      libraries: { StringTools: stringTools.address },
    });
    gear = await Gear.deploy(amount, price, uris);
  });

  it("Should have all links stored correctly", async function () {
    const tx0 = await gear.getEquipmentMetadataLink(0);
    const tx1 = await gear.getEquipmentMetadataLink(1);
    const tx2 = await gear.getEquipmentMetadataLink(2);

    expect(tx0).to.equal("l1");
    expect(tx1).to.equal("l2");
    expect(tx2).to.equal("l3");
  });

  it("should mint until error", async function () {
    [owner, signer1, ...addrs] = await ethers.getSigners();

    await expect(gear.mintEquipment(signer1.address, 2)).to.be.revertedWith(
      "Insuficient funds for buying this equipment"
    );
    await gear.mintEquipment(signer1.address, 2, {
      value: ethers.utils.parseEther("0.03"),
    });
    await expect(gear.mintEquipment(signer1.address, 2)).to.be.revertedWith(
      "No more equipment of this type available for minting"
    );
  });
});
