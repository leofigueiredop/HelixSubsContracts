const hre = require("hardhat");

async function main() {


   const { Wallet } = require('ethers');

  const wallet = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c')
  const types = ['uint256',
              'address[4]', 
              'uint256[3]', 
                    'uint', 
                  'string']
  let values = [1, 
    ["0xC848B73c7266d8402Dc3b1D9bC8f90826E08d944","0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2" ],
    [hre.ethers.utils.parseUnits("3"),hre.ethers.utils.parseUnits("3"), hre.ethers.utils.parseUnits("6")],
    1,
    "1234/LEONARDO/LEO.PIC@GMAIL.COM"]

  let solidityHash = ethers.utils.solidityKeccak256(types, values);
 
  let sign = await wallet.signMessage(ethers.utils.arrayify(solidityHash));
  
  const r = sign.substr(0, 66);
  const s = `0x${sign.substr(66, 64)}`;
  const v = `0x${sign.substr(130, 2)}`;


  const Sub = await hre.ethers.getContractFactory("HelixSubs");
  const subs = Sub.attach("0x6131CA11210B6aa47D743895FeE4BCDfb869a4b3")
  const result = await subs.Subscribe(1,
                                    ["0xC848B73c7266d8402Dc3b1D9bC8f90826E08d944","0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2" ],
                                    [hre.ethers.utils.parseUnits("3"),hre.ethers.utils.parseUnits("3"), hre.ethers.utils.parseUnits("6")],
                                    1,
                                    "1234/LEONARDO/LEO.PIC@GMAIL.COM",v,r,s)

 
  console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

