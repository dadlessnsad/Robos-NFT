const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RobosNFT Test", function () {

    let robosNFT;
    let robos;
    let BoltsToken
    let boltsToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;


    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        robosNFT = await ethers.getContractFactory("RobosNFT");
        [owner, addr1, addr2, addr3] = await ethers.getSigners();

        robos = await robosNFT.deploy("RobosNFT", "RBT", "IPFS://gfdsgds/", ["Rayne"], [1]);
        await robos.deployed();

        BoltsToken = await hre.ethers.getContractFactory("BoltsToken");
        boltsToken = await BoltsToken.deploy(robos.address);
        await boltsToken.deployed();
          
        const setBoltTokenTx = await robos.setBoltsToken(boltsToken.address);    
        await setBoltTokenTx.wait();
    });
      // You can nest describe calls to create subsections.
    describe("Deployment", function () {

        it("Should set the right owner", async function () {
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

        it("Should set addr1 as whitelised", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.whitelistUsers([addr1.address]);

            expect(await robos.isWhitelisted(addr1.address)).to.equal(true)
        })

        it("Should allow addr1 to whitelist mint", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.whitelistUsers([addr1.address]);

            const tx = await robos.connect(addr1).whitelistMint(4, {
                value: ethers.utils.parseEther("0.4")
            })

            expect(await robos.balanceOG(addr1.address)).to.equal(4);
            expect(await robos.robosSupply()).to.equal(64);
        })

        it("Should only allow addr1 to whitelist mint 4 tokens", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.whitelistUsers([addr1.address]);
            
            const tx = await robos.connect(addr1).whitelistMint(4, {
                value: ethers.utils.parseEther("0.4")
            })

            expect(robos.connect(addr1).whitelistMint(4)).to.be.revertedWith('max per address');
            expect(await robos.balanceOG(addr1.address)).to.equal(4);
            expect(await robos.robosSupply()).to.equal(64);
        })

        it("Should Fails if addr1 is not whitelisted", async function () {
            const setPause = await robos.pause(false);
            expect(robos.connect(addr1).whitelistMint(4)).to.be.revertedWith('not whitelisted');
        })

        it("Should have Whitelist as False", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(await robos.preSale()).to.equal(false);
        })

        it("Should only allow bulkBuyLimit during mint", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).whitelistMint(10)).to.be.reverted
        })

        it("Should track token supply", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            console.log(await robos.robosSupply())

            const tx1 = await robos.connect(addr1).mintGenesisRobo(8, {
                value: ethers.utils.parseEther("0.8")
            })

            const tx2 = await robos.connect(addr1).mintGenesisRobo(8, {
                value: ethers.utils.parseEther("0.8")
            })

            const tx3 = await robos.connect(addr1).mintGenesisRobo(8, {
                value: ethers.utils.parseEther("0.8")
            })

            const tx4 = await robos.connect(addr1).mintGenesisRobo(8, {
                value: ethers.utils.parseEther("0.8")
            })
            // premint =25 || 25 + 8 + 8 + 8
            expect(await robos.robosSupply()).to.equal(92)
        })

        it("Should revert with presale over", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).whitelistMint(1)).to.be.reverted
        })

        it("Should fail with wrong value sent", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);

            expect(robos.connect(addr1).mintGenesisRobo(8, {
                value: ethers.utils.parseEther("0.4")
            })).to.be.reverted
        })
        
        it("Should not allow user to claim Boltstoken if not owner of a Robo", async function () {
            const setPause = await robos.pause(false);
            const setWhitelsit = await robos.setOnlyPreSale(false);
            expect(robos.connect(addr1).getReward()).to.be.reverted; 
        })
        
        // it("Should allow user to claim Boltstoken if owner of a Robo", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     const tx = await robos.connect(addr1).mintGenesisRobo(8, {
        //         value: ethers.utils.parseEther("0.8")
        //     })

        //     const balance = await boltsToken.balanceOf(addr1.address);
        //     console.log(balance)
        //     expect(boltsToken.balanceOf(addr.address)).to.equal(8000000000000000000000000000)
        // })
        
        // it("Should revert if user dosent own both tokens", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     const enable = await robos.enableBreeding()

        //     expect(await robos.manufactureRoboJr(60, 2)).to.be.reverted;
        // })
        
        // it("Should allow user to breedRoboJr", async function () {
        //     const setPause = await robos.pause(false);
        //     const setWhitelsit = await robos.setOnlyPreSale(false);
        //     const tx = await robos.connect(addr1).mintGenesisRobo(2, {
        //         value: ethers.utils.parseEther("0.2")
        //     })

        //     const enable = await robos.enableBreeding()

        //     const getrewarded = await robos.getReward(addr1.address);

        //     const breed = await robos.connect(addr1).manufactureRoboJr(61, 62);

        //     expect(await robos.balanceJR(addr1.address)).to.Equal(1);

        // })
    })
})

