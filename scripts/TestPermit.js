const { ethers } = require("hardhat")
const { contractABI } = require("./ContractABi")



async function main() {
    const accounts = await ethers.getSigners(1);
    const signer = accounts[0];
    const contractAddress = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
    const MiddleWareadd = '0x9a552a9c8dc98f76f52a9CB739EA560D1a8E74a0';
    const token = await ethers.getContractFactory("MiddleWare" );
    token.attach(MiddleWareadd);
    const spender = "0x81d5601a83ab7F1d89DcD0E25d676884f12Fa9C6";
    const deadline = ethers.constants.MaxUint256;
    const amount = 1000;

    signer._signTypedData

    const { v, r, s } = await getPermitSignature(
      signer,
      token,
      spender,
      amount,
      deadline
    )
console.log("v",v);
console.log("r",r);
console.log("s",s);
console.log("dead",deadline);

   //await token. .forwardPermit(contractAddress, spender,   amount,  deadline,  v,  r,  s);
    

   //console.log("response:", response);
    
  }
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


  async function getPermitSignature(signer, token, spender, value, deadline) {
    const [nonce, name, version, chainId] = await Promise.all([
      0,
      "USD Coin",
      "2",
      await signer.getChainId(),
    ])
    console.log("chainid",await signer.getChainId());
    console.log("sign add",signer.address);
    return ethers.utils.splitSignature(
      await signer._signTypedData(
        {
          name,
          version,
          chainId,
          verifyingContract: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        },
        {
          Permit: [
            {
              name: "owner",
              type: "address",
            },
            {
              name: "spender",
              type: "address",
            },
            {
              name: "value",
              type: "uint256",
            },
            {
              name: "nonce",
              type: "uint256",
            },
            {
              name: "deadline",
              type: "uint256",
            },
          ],
        },
        {
          owner: "0x9eC9b187CB10c71c1e87d3D319C341C1850893c2",
          spender,
          value,
          nonce,
          deadline,
        }
      )
    )
  }