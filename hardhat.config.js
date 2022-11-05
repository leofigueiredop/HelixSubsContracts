const { Network } = require("alchemy-sdk");

require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/6c9abdd3278e4bf89314f691128dc225',
      accounts: ['0x2d00fa225bb7e62095e3233aecd8c6b81ea550dad5ee6eccc7138e5a06a2ba27']
    },
    bsctest: {  
    url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
   // accounts: ['b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c'],
    accounts: ['f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f'],    
    },
    mumbai: {
      url: 'https://rpc-mumbai.matic.today',
     // accounts: ['f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f'],8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3
      accounts: ['8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3'],
      chainId:80001
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      chainId: 137,
      accounts: ['b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c'],//pvt housemagOwner
     //accounts: ['8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3'],//manager
      // gasPrice:100000000000, gasLimit: 1000000
    },
    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/hviQS-g315FfKuoy7bNil13div4ZDEeO',
      // accounts: ['f808fb48dbfc717b02053e5abe31a05967ca12bae6e217c7025ce70e1a67755f'],8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3
       accounts: ['8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3'],
       chainId: 5
     //api key hviQS-g315FfKuoy7bNil13div4ZDEeO

    }
  },
  
  etherscan: {
     //apiKey:"CI6R71WXT53PNFPB33E4M6J428WVPIKV2K", //bstteste
     //apiKey:"V12DZM2BRXHZ8HG5UAN5HZTNIGVR1CRF4Z", //eth
     apiKey:"NE6D9Z8MQSHDAIDQX34SKAY75MUE3SBSPP", //poly
  }
};
