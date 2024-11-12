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
// =========Deploying RewardDispatcher===========
// Contract address:  0xC4708854dB13492C9411C17B97DC41bB9370eCD5