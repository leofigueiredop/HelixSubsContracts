const { ethers } = require("hardhat");
const hre = require("hardhat");
const contractABI =
      '[{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]'

async function main() {
//Set price to 1 Gwei
let gasPriceHex = ethers.utils.hexlify(8000000000);
//Set max gas limit to 4M
var gasLimitHex = ethers.utils.hexlify(4000000);

    const { Wallet } = require('ethers');
    const walletsign = new Wallet('f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f');
    
    const spender = "0x32bF4C3Cd231D7ebCD30A87c272030DC21786d33";
    const value = hre.ethers.utils.parseUnits("10");
    const contractAddress = '0x99386430cb1d8b3b93F50E31C12AAf79492009CF';
    const contract = new ethers.Contract(contractAddress, contractABI, walletsign );

     const params = [spender, value];
     const action = 'approve';

    // Raw Transaction
    var rawTx = {
        spender : spender,
        amount : value
    };
    let unsignedTx = await contract.populateTransaction[action](spender, value)
    let signedtx = await walletsign.signTransaction(unsignedTx);
    unsignedTx.sign(Buffer.from("f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f", "hex"));

    //const walletsend = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c');

    const tx = await ethers.provider.getSigner().sendTransaction( "0x" + signedtx.serialize().toString("hex") );
    

    console.log("return", tx);

    
    // https://docs.ethers.io/v5/api/signer/#Signer-populateTransaction
    
    

}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  