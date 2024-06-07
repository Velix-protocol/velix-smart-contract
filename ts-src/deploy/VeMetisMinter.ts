import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("VeMetisMinter", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: ["0x70A4e12BbBD6AD0c1240203acCA6DD78941A3ee7"],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
};

func.tags = ["VeMetisMinter"];

export default func;