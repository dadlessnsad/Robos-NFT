const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require('keccak256');

describe("RobosNFT Test", function () {

    let robosNFT;
    let robos;
    let ClankToken
    let clankToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;


    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        robosNFT = await ethers.getContractFactory("RobosNFT");
        [owner, addr1, addr2, addr3] = await ethers.getSigners();

        robos = await robosNFT.deploy("RobosNFT", "RBT", "IPFS://gfdsgds/", ["bobby"], [1]);
        await robos.deployed();

        ClankToken = await hre.ethers.getContractFactory("ClankToken");
        clankToken = await ClankToken.deploy(robos.address);
        await clankToken.deployed();
          
        const setClankTokenTx = await robos.setClankToken(clankToken.address);    
        await setClankTokenTx.wait();
        
    });
      // You can nest describe calls to create subsections.
    describe("Deployment", function () {

        it("Should set the right owner", async function () {
            const xurg = await robos.owner()
            console.log(xurg)

            expect(await robos.owner()).to.equal(owner.address);
            
        }); 
        
        it("should fail if paused, ", async function () {
            expect(robos.connect(addr1).mintGenesisRobo()).to.be.reverted;
            
        })

        it("Should set paused to false", async function () {
            const setPause = await robos.pause(false);

            expect(await robos.paused()).to.equal(false);
        })

        it("should set Whitelist True, ", async function () {
            const setPause = await robos.pause(false);
            const whitelist = await robos.preSale();
            expect(await robos.preSale()).to.equal(true);
        })

        it("SHould WL mint, ", async function () {
            const setPause = await robos.pause(false);

            let addresses = [
                addr1.address,
                addr2.address,
              ]
            let leaves = addresses.map(addr => keccak256(addr))
            let merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true})
            let rootHash = merkleTree.getRoot().toString('hex')
            const setMerkleRoot = await robos.setWLMerkleRoot(`0x${rootHash}`)
            let address = addresses[0]
            let hashedAddress = keccak256(address)
            let proof = merkleTree.getHexProof(hashedAddress)

            console.log(hashedAddress, proof)
            const tx1 = await robos.connect(addr1).whitelistMint(proof, 2, {
                value: ethers.utils.parseEther("0.2")
            })

            expect(await robos.robosSupply()).to.equal(62)      
        })

        it("Should fail in user not WL", async function () {
            const setPause = await robos.pause(false);
  
            let addresses = [
              addr1.address,
              addr2.address,
            ]
            let leaves = addresses.map(addr => keccak256(addr))
            let merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true})
            let rootHash = merkleTree.getRoot().toString('hex')
            const setMerkleRoot = await robos.setWLMerkleRoot(`0x${rootHash}`)
            let address = addresses[0]
            let hashedAddress = keccak256(address)
            let proof = merkleTree.getHexProof(hashedAddress)
  
            const mint = await robos.connect(addr1).whitelistMint(proof, 2, {
              value: ethers.utils.parseEther("0.2")
            })
            
            expect(robos.connect(addr3).whitelistMint(proof, 1, {
              value: ethers.utils.parseEther("0.1")
            })).to.be.revertedWith('Address does not exist in list')
          })

        // it("Should set addr1 as whitelised", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.whitelistUsers([addr1.address]);
        //     expect(await robos.isWhitelisted(addr1.address)).to.equal(true)
        // })

        // it("Should allow addr1 to whitelist mint", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.whitelistUsers([addr1.address]);

        //     const tx = await robos.connect(addr1).whitelistMint(2, {
        //         value: ethers.utils.parseEther("0.2")
        //     })
        //     expect(await robos.balanceOG(addr1.address)).to.equal(2);
        //     expect(await robos.robosSupply()).to.equal(62);
        // })

        // it("Should only allow addr1 to whitelist mint 2 tokens", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.whitelistUsers([addr1.address]);
            
        //     const tx = await robos.connect(addr1).whitelistMint(2, {
        //         value: ethers.utils.parseEther("0.2")
        //     })
        //     expect(robos.connect(addr1).whitelistMint(4)).to.be.revertedWith('max per address');
        //     expect(await robos.balanceOG(addr1.address)).to.equal(2);
        //     expect(await robos.robosSupply()).to.equal(62);
        // })

        // it("Should Fails if addr1 is not whitelisted", async function () {
        //     const setPause = await robos.pause(false);
        //     expect(robos.connect(addr1).whitelistMint(4)).to.be.revertedWith('not whitelisted');
        // })

        // it("Should have Whitelist as False", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     expect(await robos.preSale()).to.equal(false);
        // })

        it("Should only allow bulkBuyLimit during mint", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).whitelistMint(10)).to.be.reverted
        })

        it("Should track token supply", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            console.log(await robos.robosSupply())

            const tx1 = await robos.connect(addr1).mintGenesisRobo(4, {
                value: ethers.utils.parseEther("0.4")
            })

            // const tx2 = await robos.connect(addr1).mintGenesisRobo(8, {
            //     value: ethers.utils.parseEther("0.8")
            // })

            // const tx3 = await robos.connect(addr1).mintGenesisRobo(8, {
            //     value: ethers.utils.parseEther("0.8")
            // })

            // const tx4 = await robos.connect(addr1).mintGenesisRobo(8, {
            //     value: ethers.utils.parseEther("0.8")
            // })
            // premint =25 || 25 + 8 + 8 + 8
            expect(await robos.robosSupply()).to.equal(64)
        })

        it("Should revert with presale over", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).whitelistMint(1)).to.be.reverted
        })

        it("Should fail with wrong value sent", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).mintGenesisRobo(4, {
                value: ethers.utils.parseEther("0.3")
            })).to.be.reverted
        })

        it("Should not allow user to claim Boltstoken if not owner of a Robo", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).getReward()).to.be.reverted; 
        })

        // it("Should not allow user to claim Boltstoken from bolts contract", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     const mintRobo = await robos.connect(addr1).mintGenesisRobo(2, {
        //         value: ethers.utils.parseEther("0.2")
        //     })

        //     const balance = await robos.connect(addr1).balanceOG()
        //     console.log(await balance);

        //     console.log(await robos.connect(addr1).getReward());
        //     expect(boltsToken.connect(addr1).getReward(addr1.address)).to.be.reverted;
        // })


        
        // it("Should allow user to claim Boltstoken if owner of a Robo", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     const tx = await robos.connect(addr1).mintGenesisRobo(8, {
        //         value: ethers.utils.parseEther("0.8")
        //     })

        //     const balance = await boltsToken.balanceOf(addr1.address);
        //     console.log(balance)
        //     //expect(robos.connect(addr1).getReward()).changeTokenBalance(boltsToken, balance);
        // })
        
        it("Should revert if user dosent own both tokens", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            const enable = await robos.enableBreeding()

            expect(robos.connect(addr2).manufactureRoboJr(60, 2)).to.be.reverted;
        })
        
        it("Should allow user to breedRoboJr", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            const tx = await robos.connect(owner).mintGenesisRobo(2, {
                value: ethers.utils.parseEther("0.2")
            })

            const enable = await robos.enableBreeding()

            const getrewarded = await robos.getReward(owner.address);

            const breed = await robos.connect(owner).manufactureRoboJr(61, 62);

            expect(await robos.roboJrSupply()).to.equal(1)
        })
    })
})

