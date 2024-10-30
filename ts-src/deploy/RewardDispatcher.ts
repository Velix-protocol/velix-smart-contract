import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying RewardDispatcher");
 const result = await deploy("RewardDispatcher", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: ["0xFB45f031943759FFa793aC19d0e47aE9723EbF9a"],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
  console.log("=========Deploying RewardDispatcher===========");
  console.log("Contract address: ", result.address);
};

func.tags = ["RewardDispatcher"];

export default func;

// Deploying RewardDispatcher
// deploying "DefaultProxyAdmin" (tx: 0xbf073700e0e68b0701fc719259ca204f1940c0f0f100266828914238907cc51a)...: deployed at 0x8fb227396C472A28cb5B614eeF8d4eE638b87734 with 643983 gas
// deploying "RewardDispatcher_Implementation" (tx: 0x76a0764c1f71e964f252989bf105179cc763715880dc1554f824c2a2755a4e24)...: deployed at 0x48ad193A70c787B67367c1Fc3d6b4A2aE73846eC with 1674763 gas
// deploying "RewardDispatcher_Proxy" (tx: 0x3314d6460d3b9d1695d2502030de0b98e155a8719f8844b5678bf1419f69eb01)...: deployed at 0x77Be5d0814164596D5558c6f4D3EF68A9Af16366 with 828153 gas
// =========Deploying RewardDispatcher===========
// Contract address:  0x77Be5d0814164596D5558c6f4D3EF68A9Af16366