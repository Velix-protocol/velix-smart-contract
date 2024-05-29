import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying RewardDispatcher");
  await deploy("RewardDispatcher", {
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
  console.log("=========Deploying RewardDispatcher===========");

};

func.tags = ["RewardDispatcher"];

export default func;

// reusing "DefaultProxyAdmin" at 0x349f3de199C7FD5e4a1d756D2857B9Ca5f5F6576
// reusing "RewardDispatcher_Implementation" at 0xED453D3215FC8f1Da37cC2D115b265e4d2d435A1
// deploying "RewardDispatcher_Proxy" : 0x873f69c397546a89024B770379958D3aDE671729