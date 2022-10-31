const hre = require("hardhat");

async function main() {

   const { Wallet } = require('ethers');

   const productID = '1'
   let tokenMerchantHelixCreator_addr = [
        '0x40774390d0C2032Fb8aFEc3a0D6220969746a32B',
        '0x2D5801D3C8b6C42c9d50004958909A80e5212b55',
        '0x40774390d0C2032Fb8aFEc3a0D6220969746a32B',
        '0x4fa37e650a732Db793f277819d081f5D8FAC7117',
      ]
   let merchantHelixCreator_value = [
        ethers.utils.parseUnits('1'),
        ethers.utils.parseUnits('1'),
        ethers.utils.parseUnits('10'),
      ]
      const recurrence = 30
      const userData = 'Giverson'

      const wallet = new Wallet(
        'b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c'
      )
      const types = ['string', 'address[4]', 'uint256[3]', 'uint', 'string']
      let values = [
        productID,
        tokenMerchantHelixCreator_addr,
        merchantHelixCreator_value,
        recurrence,
        userData,
      ]

      let solidityHash = ethers.utils.solidityKeccak256(types, values)

      let sign = await wallet.signMessage(ethers.utils.arrayify(solidityHash))

      const r = sign.substr(0, 66)
      const s = `0x${sign.substr(66, 64)}`
      const v = `0x${sign.substr(130, 2)}`


  const Sub = await hre.ethers.getContractFactory("HelixSubs");
  const subs = Sub.attach("0x273D1BF1b8b1d4888F157Ca0912BCC94AB0C166b")
  const result = await subs.Subscribe( productID,tokenMerchantHelixCreator_addr,merchantHelixCreator_value,recurrence,userData,v,r,s, 
    { gasPrice:200000000000, gasLimit: 20000000})
 
  console.log("Return", result);
 


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

