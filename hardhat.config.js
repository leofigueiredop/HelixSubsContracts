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
    accounts: ['b2640088b2fb0c3484de1add4c41f9814f225d91788b5cdf58869d116803ad3c']
    },
    mumbai: {
      url: 'https://rpc-mumbai.matic.today',
      accounts: ['8d89f4db44390b327165d38c2160d6c1f352e0b929a704d402fa3bad2aa279d3']
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      accounts:['287c97ccc5a13adb270cb407a153ae7580fc38cc800fb1a1542228955684c7fe'],//pvt MetakitOwner
      
    }
  },
  
  etherscan: {
     apiKey:"CI6R71WXT53PNFPB33E4M6J428WVPIKV2K", //bstteste
     //apiKey:"V12DZM2BRXHZ8HG5UAN5HZTNIGVR1CRF4Z", //eth
    //poly apiKey:"NE6D9Z8MQSHDAIDQX34SKAY75MUE3SBSPP",
  }
};
