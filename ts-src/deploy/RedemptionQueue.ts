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
          args: ["0xFB45f031943759FFa793aC19d0e47aE9723EbF9a"],
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
// reusing "DefaultProxyAdmin" at 0xDBb3388EA28b9135e05e5fC389Ce75f736249A7a
// deploying "RedemptionQueue_Implementation" (tx: 0x7e2cecaedbfcded63e09aac44d804597719bdaaa20b0d2f880b38fbcf2f8aebd)...: deployed at 0x8209539EF5Df19F3cB8715221948baAC6a74feEC with 5851200 gas
// executing DefaultProxyAdmin.upgrade (tx: 0xcc655e174ff1469c8d874b8b2b6013a9eea58fafa0a803b872b0614e7086c759) ...: performed with 38688 gas
// ========Deploying RedemptionQueue========
// Contract address:  0x96C35AAe0730c625816bC3eb5cf28f68A309ef7b