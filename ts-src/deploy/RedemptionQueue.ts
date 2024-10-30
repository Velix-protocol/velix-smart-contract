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
// deploying "RedemptionQueue_Implementation" (tx: 0xb1c4293a653309959c59f29d8691e808db111b4db169087c4ea13142756da9df)...: deployed at 0xd75fb4cB59D60B70DA081c6c1e520AEdbFF60f1a with 5823767 gas
// deploying "RedemptionQueue_Proxy" (tx: 0x4f94c34fad4fb947f7f12ca9fed4fd91445494162a1778be22b1fd33706ff25c)...: deployed at 0x96C35AAe0730c625816bC3eb5cf28f68A309ef7b with 900726 gas
// ========Deploying RedemptionQueue========
// Contract address:  0x96C35AAe0730c625816bC3eb5cf28f68A309ef7b