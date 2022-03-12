const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  const Shaker = await ethers.getContractFactory("Shaker", {
    libraries: { StringTools: "0xEb06550a64F3290C909F6A8036318AAA94E44730" },
  });
  const shaker = Shaker.attach("0xA7665044081e48D3B3316abaadB3179CA804C48A");

  let tx = await shaker.mintShaker(2, {
    value: ethers.utils.parseEther("0.03"),
  });
  console.log(tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
