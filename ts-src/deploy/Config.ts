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
// reusing "DefaultProxyAdmin": 0x349f3de199C7FD5e4a1d756D2857B9Ca5f5F6576
// deploying "Config_Implementation": 0xcbd9689f170588f8079134F44d2A5fD5C57d1cAE 
// deploying "Config_Proxy": 0x70A4e12BbBD6AD0c1240203acCA6DD78941A3ee7 
