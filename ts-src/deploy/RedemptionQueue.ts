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
          args: ["0xFB6E65f3d6207f326A6B88830b1E35c1F98BF25d"],
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
// Contract address:  0x5F38472BC3ad03eaadB93dC168b49A5871B0E128