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
          args: ["0xFB45f031943759FFa793aC19d0e47aE9723EbF9a"],
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

// Deploying VeMetis
// reusing "DefaultProxyAdmin" at 0x9522454B069f510a73Ab7179C8826Fc917514DF3
// deploying "VeMetis_Implementation" (tx: 0x205976f21ab795d03de64b15995093703d1470167309285bda9a2f1404b3c8ed)...: deployed at 0x4CCC919aB5616Eb8fF9A9d81148Ea96215301F45 with 1726587 gas
// deploying "VeMetis_Proxy" (tx: 0x01476c283d2b8306f4505c8d1845e44c766b816da599a40cc5bdd80ba83f6a08)...: deployed at 0xfB74f0f75F10E31cDB84dE1CAcA1ef08635F2587 with 839184 gas
// ========Deploying VeMetis========
// Contract address:  0xfB74f0f75F10E31cDB84dE1CAcA1ef08635F2587