const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {

  const robosNFT = await ethers.getContractFactory("RobosNFT");
  const robos = await robosNFT.deploy("RobosNFT", "RBT", "ipfs://QmaEU6xzL1VWTWghqHyWPNebbSyirptD9cu813z5bq4bC7/", ["Bob"], [1]);
  await robos.deployed();

  console.log("RobosNFT deployed to:", robos.address);
  
  const BoltsToken = await hre.ethers.getContractFactory("BoltsToken");
  const boltsToken = await BoltsToken.deploy(robos.address);
  await boltsToken.deployed();

  console.log("Bolts Token deployed to:", robos.address);

  const setBoltTokenTx = await robos.setBoltsToken(boltsToken.address);    
  await setBoltTokenTx.wait();

  console.log(setBoltTokenTx);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
