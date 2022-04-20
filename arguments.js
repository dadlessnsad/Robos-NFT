require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const hre = require("hardhat");
const ethers = hre.ethers;

module.exports = [
  "RobosNFT",
  "RBT",
  "ipfs://QmYVpWURtBAiuk6LYW1B8wn3PpiPer9YdjYJTL26RkYU6Z/",
  ["Bob"], 
  [1]
  ];
  