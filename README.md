# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

Follow these steps to get started:

1   Create .env file from .env sample file. enter the inputs you need. aka wallet key
2   Add the Gnosis safe address to the 6th Param on line 12 of scripts/deploy.js && 2nd Param on line 18
3   Add same address as in step # 3 to arguments.js 6th param on line 14 
3   run in terminal ``npx hardhat run --network mainnet scripts/deploy.js`` to deploy contracts
4   run in terminal ``npx hardhat verify --network mainnet --constructor-args arguments.js ROBOS_CONTRACT_ADDRESS`` to verify Robos Contract
5   run in terminal ``npx hardhat verify --network mainnet CLANK_CONTRACT_ADDRESS "ROBOS_CONTRACT_ADDRESS, 0x501a676687368905E74e1C1E30ae3D6AC5Ca2bBE`` to verify Clank Contract


