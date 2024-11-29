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
         args: ["0xFB6E65f3d6207f326A6B88830b1E35c1F98BF25d"],
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
// Contract address:  0x8D0629EE59E8a1DD984990975737511039399a15