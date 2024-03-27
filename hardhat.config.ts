import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-verify";


import * as dotenv from "dotenv";
dotenv.config();

import "./ts-src/scripts/accounts";

const WALLET_PRIVATE_KEY = process.env.PRIVATE_KEY as string;
if (!process.env.PRIVATE_KEY) {
  throw new Error("No private key");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
      evmVersion: "berlin",
      metadata: {
        bytecodeHash: "none",
      },
    },
  },
  networks: {
    "metis-sepolia": {
      url: "https://sepolia.metisdevops.link",
      accounts: [WALLET_PRIVATE_KEY],
      verify: {
        etherscan: {
          apiKey: "apiKey is not required, just set a placeholder",
          apiUrl: "https://sepolia-explorer.metisdevops.link",
        },
      },
    },
    andromeda: {
      url: "https://andromeda.metis.io",
      accounts: [WALLET_PRIVATE_KEY],
      verify: {
        etherscan: {
          apiKey: "apiKey is not required, just set a placeholder",
          apiUrl:
            "https://api.routescan.io/v2/network/mainnet/evm/1088/etherscan",
        },
      },
    },
  },
  etherscan: {
    apiKey: {
      "metis-sepolia": "apiKey is not required, just set a placeholder",
      "metis-goerli": "apiKey is not required, just set a placeholder",
      andromeda: "apiKey is not required, just set a placeholder",
    },
    customChains: [
      {
        network: "andromeda",
        chainId: 1088,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/mainnet/evm/1088/etherscan",
          browserURL: "https://explorer.metis.io",
        },
      },
      {
        network: "metis-goerli",
        chainId: 599,
        urls: {
          apiURL: "https://goerli.explorer.metisdevops.link/api",
          browserURL: "https://goerli.explorer.metisdevops.link",
        },
      },
      {
        network: "metis-sepolia",
        chainId: 59902,
        urls: {
          
          apiURL: "https://sepolia-explorer.metisdevops.link/api",
          browserURL: "https://sepolia-explorer.metisdevops.link",
        },
      },
    ],
  }
  ,
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    tests: "ts-src/test",
    deploy: "ts-src/00-deploy",
  },
  sourcify: {
    enabled: true
  }
};

export default config;