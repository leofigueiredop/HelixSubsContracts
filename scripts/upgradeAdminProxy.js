const { ethers, upgrades } = require("hardhat");

const UPGRADEABLE_PROXY = "0x6907204637817353d940EC00E4a3FB7e735DEE5A";

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const V2Contract = await ethers.getContractFactory("HelixSubs");
   console.log("Upgrading V1Contract...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, V2Contract, {
      gasPrice: gas
   });
   console.log("Upgraded version");
   console.log("New Version Deployed To:", upgrade.address)
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });