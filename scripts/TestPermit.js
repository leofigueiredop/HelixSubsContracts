const { Contract } = require("alchemy-sdk");
const { ethers } = require("hardhat")



async function main() {


  const accounts = await ethers.getSigners(1);
  const signer = accounts[0];
  let provider = signer.provider;
 
  
  let signerAddress = await signer.getAddress()
  let tokenAddress = '0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747'
  
  let abi = [
    {
      inputs: [],
      name: "name",
      outputs: [
        {
          internalType: "string",
          name: "",
          type: "string"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "owner",
          type: "address"
        }
      ],
      name: "nonces",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "owner",
          type: "address"
        },
        {
          internalType: "address",
          name: "spender",
          type: "address"
        },
        {
          internalType: "uint256",
          name: "value",
          type: "uint256"
        },
        {
          internalType: "uint256",
          name: "deadline",
          type: "uint256"
        },
        {
          internalType: "uint8",
          name: "v",
          type: "uint8"
        },
        {
          internalType: "bytes32",
          name: "r",
          type: "bytes32"
        },
        {
          internalType: "bytes32",
          name: "s",
          type: "bytes32"
        }
      ],
      name: "permit",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
  ]
  
  let erc20 = new ethers.Contract(tokenAddress, abi, provider)

  let nonce = await erc20.nonces(signerAddress)
  let name = await erc20.name()
  let amount = 182666666 ;
  let deadline = 933120000000;
  let spenderAddress = '0xDD4aa8f342832f6dBB5a2710C7E616411d16e032'
  console.log(name, nonce)
  
  let PERMIT_TYPEHASH = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)'))
  //console.log('PERMIT_TYPEHASH', PERMIT_TYPEHASH) // 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9
  
  let EIP712_DOMAIN_TYPEHASH = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)'))
  //console.log('EIP712_DOMAIN_TYPEHASH', EIP712_DOMAIN_TYPEHASH) //0x36c25de3e541d5d970f66e4210d728721220fff5c077cc6cd008b3a0c62adab7
  
  let DOMAIN_SEPARATOR = ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(
      [
        'bytes32',
        'bytes32',
        'bytes32',
        'address',
        'bytes32',
      ],
      [
        EIP712_DOMAIN_TYPEHASH,
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes(name)),
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes("1")),
        tokenAddress,
        ethers.utils.hexZeroPad(ethers.BigNumber.from(80001).toHexString(), 32)
      ]
    )
  )
//console.log('DOMAIN_SEPARATOR', DOMAIN_SEPARATOR)
  
  let domain = {
    name: name,
    version: "2",
    verifyingContract: tokenAddress,
    salt: ethers.utils.hexZeroPad(ethers.BigNumber.from(80001).toHexString(), 32)
  }
  let types = {
    Permit: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
      { name: 'value', type: 'uint256' },
      { name: 'nonce', type: 'uint256' },
      { name: 'deadline', type: 'uint256' }
    ]
  }
  let value = {
    owner: signerAddress,
    spender: spenderAddress,
    value: amount,
    nonce: nonce,
    deadline: deadline
  }      
  console.log('value', value)

  const populated = await ethers.utils._TypedDataEncoder.resolveNames(domain, types, value, (name) => {
    return provider.resolveName(name);
  })
  console.log('populated', populated)
  
  let payload = ethers.utils._TypedDataEncoder.getPayload(populated.domain, types, populated.value)
  console.log('payload', payload)
  
  payload.types.EIP712Domain = [
    { name: 'name', type: 'string' },
    { name: 'version', type: 'string' },
    { name: 'verifyingContract', type: 'address' },
    { name: 'salt', type: 'bytes32' }
  ]
  
  let signature = await provider.send("eth_signTypedData_v4", [
      signerAddress.toLowerCase(),
      JSON.stringify(payload)
  ])
  console.log('signature', signature)
  
  const { v,r,s } = ethers.utils.splitSignature(signature)
  var approvalData = erc20.interface.encodeFunctionData('permit', [
    signerAddress,
    spenderAddress,
    amount,
    deadline,
    v, r, s
  ])
  console.log("v",v);
  console.log("r",r);
  console.log("s",s);
  // let tx = await signer.sendTransaction({
  //   from: signerAddress,
  //   to: tokenAddress,
  //   data: approvalData,
  //   value: ethers.constants.Zero,
  //   gasPrice: ethers.utils.parseUnits('50', 'gwei'),
  //   gasLimit: ethers.BigNumber.from(1e6),
  // })
  
  // console.log(tx)
  // let receipt = await tx.wait()
  // console.log(receipt)
  }
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });


 
 