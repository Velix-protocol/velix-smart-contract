import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying RewardDispatcher");
 const result = await deploy("RewardDispatcher", {
   from: deployer,
   proxy: {
     proxyContract: "OpenZeppelinTransparentProxy",
     execute: {
       init: {
         methodName: "initialize",
         args: ["0x4F84E5882E6ef2bA953f1A2C6594855EB38F4c91"],
       },
     },
   },
   waitConfirmations: 1,
   log: true,
 });
  console.log("=========Deploying RewardDispatcher===========");
  console.log("Contract address: ", result.address);
};

func.tags = ["RewardDispatcher"];

export default func;
// Deploying RewardDispatcher
// reusing "DefaultProxyAdmin" at 0x06E779a4332016a3b10C6C7331d74c422d2B2640
// deploying "RewardDispatcher_Implementation" (tx: 0xf2bec0edae7a86eebc61825e4ccadbdc0ab6cd53f0d4e43362028ab8cc14d6d9)...: deployed at 0x15e31C2ecc6F50CdF582D5183fb0Dbd86b181D28 with 1667448 gas
// deploying "RewardDispatcher_Proxy" (tx: 0x33523f6a20de3ba269cc2ca01033999c6a9d4d5e564ff53c2315eb1ec6258060)...: deployed at 0xC4708854dB13492C9411C17B97DC41bB9370eCD5 with 792904 gas
// =========Deploying RewardDispatcher===========
// Contract address:  0xC4708854dB13492C9411C17B97DC41bB9370eCD5