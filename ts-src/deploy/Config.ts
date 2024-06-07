import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying Config");
  await deploy("Config", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
  console.log("========Deploying Config========");
};

func.tags = ["Config"];

export default func;
// ========Deploying and Verifying Config========
// deploying "DefaultProxyAdmin" deployed at 0x1771B0E0df123ABe65689bCEF15Fd6D03aCdE2a6
// deploying "Config_Implementation" deployed at 0x1AA8D04a6Ef1208852f75bEa94aE852Bd9106185
// deploying "Config_Proxy"  deployed at 0x241648DD30c31eb6bADDc427c2ac05E4Cf3c8908
// ========Deploying Config========