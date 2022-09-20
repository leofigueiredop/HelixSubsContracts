

async function main() {

  const HelixSubs = await hre.ethers.getContractFactory("HelixSubs");
  const _HelixSubs = await HelixSubs.deploy();

  await _HelixSubs.deployed();

  console.log(
    `HelixSubs deployed to ${_HelixSubs.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
