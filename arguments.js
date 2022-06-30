require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const hre = require("hardhat");
const ethers = hre.ethers;

module.exports = [
  "RobosNFT",
  "RBT",
  "ipfs://FakeURI/",
  ["Bob", "Alice", "Charlie", "Dave"], 
  [1, 2, 3, 4],
  "0x4BE50DAF1339DA3dA8dDC130F8CE54Aa10eF2dc6"
  ];
  