const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


   const { Wallet } = require('ethers');

 
  const Sub = await hre.ethers.getContractAt("MaticFiatToken","0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747");
  
  const result = await Sub.claim();

 
  console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

