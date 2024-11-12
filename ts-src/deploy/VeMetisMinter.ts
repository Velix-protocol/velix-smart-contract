import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying VeMetisMinter");
  const result = await deploy("VeMetisMinter", {
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
  console.log("========Deploying VeMetisMinter========");
  console.log("Contract address: ", result.address);
};

func.tags = ["VeMetisMinter"];

export default func;
// ========Deploying VeMetisMinter========
// Contract address:  0x82c6D49F563D87F8D95bDd7350174d0314401B18