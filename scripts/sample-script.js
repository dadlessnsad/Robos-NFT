// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const robosNFT = await ethers.getContractFactory("RobosNFT");
  const robos = await robosNFT.deploy("RobosNFT", "RBT", "IPFS://gfdsgds/", ["Rayne"], [1]);
  await robos.deployed();

  console.log("RobosNFT deployed to:", robos.address);
  
  const YieldToken = await hre.ethers.getContractFactory("YieldToken");
  const roboToken = await YieldToken.deploy(robos.address);

  await roboToken.deployed();

  console.log("YieldToken deployed to:", roboToken.address);

  const setYieldTokenTx = await robos.setYieldToken(roboToken.address);

  await setYieldTokenTx.wait();


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
