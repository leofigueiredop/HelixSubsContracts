const { ethers } = require("hardhat");
const hre = require("hardhat");
const contractABI =
      '[,{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"stateMutability":"nonpayable","type":"function"}]'

async function main() {
    const { Wallet } = require('ethers');
    const walletsign = new Wallet('b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c');
    const walletssend = new Wallet('f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f');
    
    const spender = "0x66b4B2C387e725Da00c76BB111D65301DC25ff51";
    const owner = "0x66b4B2C387e725Da00c76BB111D65301DC25ff51";
    const deadline = "10000000000000000";
    const amount = hre.ethers.utils.parseUnits("18");
    const contractAddress = '0xDD9185DB084f5C4fFf3b4f70E7bA62123b812226';
    const contract = new ethers.Contract(contractAddress, contractABI, walletsign );
    const action = 'permit';

    const types = ['address',
    'address', 
    'uint256', 
    'uint256', 
    'uint8',
  ]
let values = [1, 
["0xC848B73c7266d8402Dc3b1D9bC8f90826E08d944","0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2", "0x8771c36d9E629F0033cc939bF3cB7BC494386DB2" ],
[hre.ethers.utils.parseUnits("3"),hre.ethers.utils.parseUnits("3"), hre.ethers.utils.parseUnits("6")],
1,
"LEONARDO"]

let solidityHash = ethers.utils.solidityKeccak256(types, values);

let sign = await wallet.signMessage(ethers.utils.arrayify(solidityHash));

const r = sign.substr(0, 66);
const s = `0x${sign.substr(66, 64)}`;
const v = `0x${sign.substr(130, 2)}`;

    let nonceTX = await await ethers.provider.getSigner().getTransactionCount();
    console.log("nonce", nonceTX);
    const dataTX = await (await contract.populateTransaction[action](spender, amount)).data;
    console.log("data", dataTX);
    
    const tx = {
      nonce: 1,
      gasPrice:100000000000,
      gasLimit: 1000000,
      chainId: 97,
      value: 0,
      data:dataTX,
      to: null
    }

    const signedtx = await walletssend.signTransaction(tx);
    // const types = ['address', 'uint256']
    // let values = [spender, amount]
    // let solidityHash = ethers.utils.solidityKeccak256(types, values);
   
   // let signedtx = await walletsign.signMessage(ethers.utils.arrayify(solidityHash));


    console.log("signed", signedtx);

    const txresponse = await ethers.provider.getSigner().sendTransaction(signedtx);
    //const txresponse = await walletssend.provider.perform("sendTransaction",signedtx)
    //eth_sendRawTransaction
   console.log("return", txresponse);

}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  