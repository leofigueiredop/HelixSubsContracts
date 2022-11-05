const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


   const { Wallet } = require('ethers');

  const wallet = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c')
  const types = ['string',
              'address[5]', 
              'uint256[3]', 
                    'uint', 
                  'string']
  let values = ["abc10", 
    ["0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174","0x0250e537f808BaC23AF1470728F9Ca466D72899d", "0xf9eA6FA836d92cb2F4816AdC96689f01F27F276a", "0xB7CdCA11bC6Bfa0dE8b7e3381372d47eF9Fa6f5F", "0x9eC9b187CB10c71c1e87d3D319C341C1850893c2" ],
    [1,1,1],
    30,
    "LEONARDO@email.com|teste|fdafbv-fvzfv-zvzxcvzxcv-"]
    // const accounts = await ethers.getSigners(1);
    // const signer = accounts[0];
    // let provider = signer.provider;
    // let erc20 = new ethers.Contract('0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174', abi, provider)

   console.log("values", values);

  let solidityHash = ethers.utils.solidityKeccak256(types, values);
 
  let sign = await wallet.signMessage(ethers.utils.arrayify(solidityHash));
  
  const r = sign.substr(0, 66);
  const s = `0x${sign.substr(66, 64)}`;
  const v = `0x${sign.substr(130, 2)}`;

  console.log("v",v);
console.log("r",r);
console.log("s",s);
  const Sub = await hre.ethers.getContractFactory("HelixSubs");
  const subs = Sub.attach("0xf20c35e7bd6ceaf12bbe3fefa85bd98b667f23a6")
  const result = await subs.Subscribe("abc10", 
  ["0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174","0x0250e537f808BaC23AF1470728F9Ca466D72899d", "0xf9eA6FA836d92cb2F4816AdC96689f01F27F276a", "0xB7CdCA11bC6Bfa0dE8b7e3381372d47eF9Fa6f5F", "0x9eC9b187CB10c71c1e87d3D319C341C1850893c2" ],
  [1,1,1],
  30,
  "LEONARDO@email.com|teste|fdafbv-fvzfv-zvzxcvzxcv-",v,r,s)

 
  console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

