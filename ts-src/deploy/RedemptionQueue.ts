import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying RedemptionQueue");
  const result = await deploy("RedemptionQueue", {
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
  console.log("========Deploying RedemptionQueue========");
  console.log("Contract address: ", result.address);
};

func.tags = ["RedemptionQueue"];

export default func;
// ========Deploying RedemptionQueue========
// Contract address:  0x6383b4CC63f2261B2bFB90Ebb2AE3587eC301218