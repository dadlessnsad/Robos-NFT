require("@nomiclabs/hardhat-etherscan");


async function Verify() {
    
    await hre.run("verify:verify", {
        address: 0xeb6DE0b2578084c3b3A45965D76567cf71B7A0eA,
        constructorArgsParams: "./args.js"
     });
}

console.log(Verify);