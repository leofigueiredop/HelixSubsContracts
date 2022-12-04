const { ethers, upgrades } = require("hardhat");

const UPGRADEABLE_PROXY = "0xDD4aa8f342832f6dBB5a2710C7E616411d16e032";

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