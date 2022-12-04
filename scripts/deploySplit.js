

async function main() {

  const Helix_SplitPayment = await hre.ethers.getContractFactory("Helix_SplitPayment");
  const _Helix_SplitPayment = await hre.upgrades.deployProxy(Helix_SplitPayment,[], {
    initializer: 'initialize',
  });

  await _Helix_SplitPayment.deployed();

  console.log(
    `HelixSubs deployed to ${_Helix_SplitPayment.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
