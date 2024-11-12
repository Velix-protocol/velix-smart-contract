import { DeployFunction } from "hardhat-deploy/types"

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying VeMetis");
  const result = await deploy("VeMetis", {
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
  console.log("========Deploying VeMetis========");
  console.log("Contract address: ", result.address);
};

func.tags = ["VeMetis"];

export default func;
// already verified: VeMetis_Proxy (0xc467683d79CEa75abF3C9181BbEcaA20B6d5aED1), skipping.