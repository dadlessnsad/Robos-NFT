const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  const RobosNFT = await ethers.getContractFactory("RobosNFT");
  const robos = await RobosNFT.deploy("RobosNFT", "RBT", "ipfs://FakeURI/",  ["Bob", "Alice", "Charlie", "Dave"], [1, 2, 3, 4], "0x4BE50DAF1339DA3dA8dDC130F8CE54Aa10eF2dc6");
  await robos.deployed();

  console.log("RobosNFT deployed to:", robos.address);
  
  const ClankToken = await hre.ethers.getContractFactory("ClankToken");
  const clankToken = await ClankToken.deploy(robos.address);
  await clankToken.deployed();

  console.log("Clank Token deployed to:", clankToken.address);

  const setClankTokenTx = await robos.setClankToken(clankToken.address);
  await setClankTokenTx.wait();

  console.log(setClankTokenTx);

}
  
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
