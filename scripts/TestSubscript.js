const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


   const { Wallet } = require('ethers');

  const wallet = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c')
  const types = ['string',
                'string',
              'address[5]', 
              'uint256[3]', 
                    'uint', 
                  'string']
  let values = [
    'a22fe519-e52f-4439-84d8-bbf526028c16',
    '0b7c3f6f-57fa-4aca-a028-c4fca4f74e32',
    [
      '0x2791bca1f2de4661ed88a30c99a7a9449aa84174',
      '0x0250e537f808bac23af1470728f9ca466d72899d',
      '0x06903b08082743ffb95f8aae556797e35663fb79',
      '0xb7cdca11bc6bfa0de8b7e3381372d47ef9fa6f5f',
      '0x9ec9b187cb10c71c1e87d3d319c341c1850893c2'
    ],
    [
      250000,
      100000,
      4650000],
    30,
    "1492306f-2ce7-440b-b059-93dbbfad7e7a123|leopickler123|leonardo.pickler123@email.com"]
    // const accounts = await ethers.getSigners(1);
    // const signer = accounts[0];
    // let provider = signer.provider;
    // let erc20 = new ethers.Contract('0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174', abi, provider)

  // console.log("values", values);

  let solidityHash = ethers.utils.solidityKeccak256(types, values);
  console.log('solidityHash', solidityHash);
 
  let sign = await wallet.signMessage(ethers.utils.arrayify(solidityHash));
  console.log('sign',sign);
  
  const r = sign.substr(0, 66);
  const s = `0x${sign.substr(66, 64)}`;
  const v = `0x${sign.substr(130, 2)}`;

  console.log("v",v);
  console.log("r",r);
  console.log("s",s);

  // const Sub = await hre.ethers.getContractFactory("HelixSubs");
  // const subs = Sub.attach("0x2dcaf327B749EB5A694E3c657D98c230060d35b1")
  // const result = await subs.Subscribe(
  //   'a22fe519-e52f-4439-84d8-bbf526028c16',
  //   '8dc4d17d-9c9f-40ad-8af1-ed222d88b370',
  //   [
  //     '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
  //     '0x0250e537f808BaC23AF1470728F9Ca466D72899d',
  //     '0x06903b08082743fFB95F8AaE556797E35663fB79',
  //     '0xB7CdCA11bC6Bfa0dE8b7e3381372d47eF9Fa6f5F',
  //     '0x9ec9b187cb10c71c1e87d3d319c341c1850893c2'],
  //   [
  //     250000,
  //     100000,
  //     4650000],
  //   30,
  //   "1492306f-2ce7-440b-b059-93dbbfad7e7a123|leopickler123|leonardo.pickler123@email.com",
  //   v,
  //   r,
  //   s
  // )

 
  // console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

