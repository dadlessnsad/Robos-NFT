require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const hre = require("hardhat");
const ethers = hre.ethers;

module.exports = [
  "RobosNFT",
  "RBT",
  "ipfs://QmQ9Ge6X8GqRWrFh3Ny2nf4M1M6rvcnfpQTEUSZLuWFY5z/",
  ["Bob"], 
  [1],
  "0x501a676687368905E74e1C1E30ae3D6AC5Ca2bBE"
  ];
  