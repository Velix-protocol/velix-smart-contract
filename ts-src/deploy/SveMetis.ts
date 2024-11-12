import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying SveMetis");
  const result = await deploy("SveMetis", {
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
  console.log("========Deploying SveMetis========");
  console.log("Contract address: ", result.address);
};

func.tags = ["SveMetis"];

export default func;
// ========Deploying SveMetis========
// Contract address:  0xc0bCCbeB4091B525C50Bd75d10C7eB2161affA6a