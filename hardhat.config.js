require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require('keccak256');

const { DEPLOYER_PRIVATE_KEY, INFURA_PROJECT_ID } = process.env;  

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    // rinkeby: {
    //   url: INFURA_PROJECT_ID,
    //   accounts: [`${DEPLOYER_PRIVATE_KEY}`]
    // }
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999
      }
    }
  },
  // gasReporter: {
  //   currency: 'USD',
  //   coinmarketcap: "ed130847-6c1e-4071-b79d-0e037d5df036",
  //   gasPrice: 50
  // },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "AY2IGT76ACUJGCSJV9SD4V4DJVFPEFH8GH"
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
  
};
