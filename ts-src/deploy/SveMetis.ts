import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying SveMetis");
  const result = await deploy("SveMetis", {
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
  console.log("========Deploying SveMetis========");
  console.log("Contract address: ", result.address);
};

func.tags = ["SveMetis"];

export default func;

// Deploying SveMetis
// reusing "DefaultProxyAdmin" at 0x8fb227396C472A28cb5B614eeF8d4eE638b87734
// deploying "SveMetis_Implementation" (tx: 0xfd897d67abdcf5a73859761dcab1e92a454317ee30b1255189738ccb2fb20176)...: deployed at 0x9d2b1F141Ede680F0b45559808aC66BBEECe9265 with 3028403 gas
// executing DefaultProxyAdmin.upgrade (tx: 0xb95539d4b7c0cc8b556f332f0e3e89bb3b502877d41c3b1a5ad7b6d38e144cc5) ...: performed with 38676 gas
// ========Deploying SveMetis========
// Contract address:  0x8D59009756e588ca10495f9B45a4dABE2Bede29E