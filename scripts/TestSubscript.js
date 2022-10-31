const hre = require("hardhat");

async function main() {


   const { Wallet } = require('ethers');

  const wallet = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c')
  const types = ['string',
              'address[4]', 
              'uint256[3]', 
                    'uint', 
                  'string']
  let values = ["10", 
    ["0xC848B73c7266d8402Dc3b1D9bC8f90826E08d944","0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2" ],
    [hre.ethers.utils.parseUnits("3"),hre.ethers.utils.parseUnits("3"), hre.ethers.utils.parseUnits("6")],
    1,
    "LEONARDO"]

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
  const subs = Sub.attach("0x9a3722DD2781275feDf192BCfd8060a8F78f9631")
  const result = await subs.Subscribe("10", 
    ["0xC848B73c7266d8402Dc3b1D9bC8f90826E08d944","0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2" ],
    [hre.ethers.utils.parseUnits("3"),hre.ethers.utils.parseUnits("3"), hre.ethers.utils.parseUnits("6")],
    1,
    "LEONARDO",v,r,s)

 
  console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

