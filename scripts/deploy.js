// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const metadataURI = [
    "bafkreiaboyryvly7cgeoawc4up5shl6cou2ll4kkomnau5fr6n4quqb34i", // Warrior
    "bafkreiavhfvbsytizdpbtoyfucbogmc4yotkovcqxmzpcbean4pvatmiku", // Mage
    "bafkreias363km3rstilk36rhqntubywx4vmpxfwhboh5eq672egnvc3wvi", // Rogue
  ];

  const avialiability = [
    { amount: 5, price: ethers.utils.parseEther("0.0") },
    { amount: 5, price: ethers.utils.parseEther("0.015") },
    { amount: 5, price: ethers.utils.parseEther("0.03") },
  ];

  console.log("Deploying String Tools");
  const StringTools = await ethers.getContractFactory("StringTools");
  const stringTools = await StringTools.deploy();
  await stringTools.deployed();
  console.log("StringTools deployed to", stringTools.address);

  console.log("Deploying Shaker");
  const Shaker = await hre.ethers.getContractFactory("Shaker", {
    libraries: { StringTools: stringTools.address },
  });
  const shaker = await Shaker.deploy(
    [0, 0, 0],
    [0, 0, 0],
    [0, 1, 2],
    metadataURI,
    avialiability
  );

  await shaker.deployed();
  console.log("Shaker deployed to:", shaker.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
