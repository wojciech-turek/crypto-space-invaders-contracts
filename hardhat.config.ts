import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  // etherscan: {
  //   apiKey: process.env.ETHERSCAN_API_KEY,
  // },
  networks: {
    "polygon-mainnet": {
      chainId: 137,
      url: "https://rpc-mainnet.maticvigil.com",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    "nahmii-testnet": {
      chainId: 4062,
      url: "https://ngeth.testnet.n3.nahmii.io/",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};

export default config;
