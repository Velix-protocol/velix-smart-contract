const { ethers } = require("hardhat");

const networkConfig = {
  sepolia: {
    name: "sepolia",
    PrivateKey: "",
    dealerAddress: "0x972C84B2d8a4678e4ee08DE19a027279847C6451",
    metisAddress: "0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000",
    redemptionQueue: "0x5F38472BC3ad03eaadB93dC168b49A5871B0E128",
    VelixVault: "0xE8D82024A98D4A62780F5f52f74E02bCc3bEb5bc",
    RewardDispatcher: "0x8D0629EE59E8a1DD984990975737511039399a15",

    rpcUrl:
      "https://eth-sepolia.g.alchemy.com/v2/3jI6emkNhmGRZ86-E7RJtkIE4qLwqMzh",
  },
};

module.exports = {
  networkConfig,
};
