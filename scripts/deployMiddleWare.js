

async function main() {

  const MiddleWare = await hre.ethers.getContractFactory("MiddleWare");
  const _MiddleWare = await MiddleWare.deploy();

  await _MiddleWare.deployed();

  console.log(
    `HelixSubs deployed to ${_MiddleWare.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
