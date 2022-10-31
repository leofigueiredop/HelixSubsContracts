const { ethers } = require("hardhat")
const contractABI =
      '[{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"stateMutability":"nonpayable","type":"function"}]'


async function getPermitSignature(signer, token, spender, value, deadline) {
    console.log("here:", "1");

  const [nonce, name, version, chainId] = await Promise.all([
    token.signer.getTransactionCount(),
    "USD Coin (PoS)",
    "1",
    signer.getChainId(),
  ])
  console.log("name:", name);

  return ethers.utils.splitSignature(
    await signer._signTypedData(
      {
        name,
        version,
        chainId,
        verifyingContract: token.address,
      },
      {
        Permit: [
            {PERMIT_TYPEHASH: }
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
        owner: signer.address,
        spender,
        value,
        nonce,
        deadline,
      }
    )
  )
}
async function main() {
    const accounts = await ethers.getSigners(1);
    const signer = accounts[0];
    const contractAddress = '0xDD9185DB084f5C4fFf3b4f70E7bA62123b812226';
    const token = new ethers.Contract(contractAddress, contractABI, signer );
    const spender = "0x81d5601a83ab7F1d89DcD0E25d676884f12Fa9C6";
    const deadline = ethers.constants.MaxUint256;
    const amount = hre.ethers.utils.parseUnits("18");

   console.log("signer:", signer.address);

    const { v, r, s } = await getPermitSignature(
      signer,
      token,
      spender,
      amount,
      deadline
    )
    console.log("here:", "yep");

   const response =  await token.permit(signer.address,spender,amount, deadline, v, r, s)

   console.log("response:", response);
    
  }
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });