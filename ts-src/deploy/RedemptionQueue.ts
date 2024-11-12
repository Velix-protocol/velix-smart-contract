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
// Deploying RedemptionQueue
// reusing "DefaultProxyAdmin" at 0x06E779a4332016a3b10C6C7331d74c422d2B2640
// deploying "RedemptionQueue_Implementation" (tx: 0x8ed0a30cd1ce34ad73cedb1c34e870d8207775a4c9b14af45137af9caf248b71)...: deployed at 0x9eC6d44e05D19140823Be6Ac1B14Cdf929B2d92B with 3565807 gas
// deploying "RedemptionQueue_Proxy" (tx: 0xd05d58c99d37084050ffad66f24748a6fbecd0ce4f62f507a815b3c3f8143463)...: deployed at 0x6383b4CC63f2261B2bFB90Ebb2AE3587eC301218 with 900792 gas
// ========Deploying RedemptionQueue========
// Contract address:  0x6383b4CC63f2261B2bFB90Ebb2AE3587eC301218