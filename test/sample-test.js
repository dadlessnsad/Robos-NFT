const { ethers } = require("hardhat");

describe("RobosNFT", function () {
  it("hello", async function () {
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


  });
});
