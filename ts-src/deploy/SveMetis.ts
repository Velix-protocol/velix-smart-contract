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
          args: ["0x4F84E5882E6ef2bA953f1A2C6594855EB38F4c91"],
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
// reusing "DefaultProxyAdmin" at 0x06E779a4332016a3b10C6C7331d74c422d2B2640
// deploying "SveMetis_Implementation" (tx: 0xc45faf7137ff40e58f485fa4e640b428e9f6f87dc1f34eb36f05744af593c3b3)...: deployed at 0x1cc2082e0022497E6Aa1386633EC9A5d90D3d7E4 with 3028403 gas
// deploying "SveMetis_Proxy" (tx: 0x7cb0657ca702b8c348a79c44789036932a40268e5bfa482a869d0a63a7a98f1c)...: deployed at 0xc0bCCbeB4091B525C50Bd75d10C7eB2161affA6a with 909113 gas
// ========Deploying SveMetis========
// Contract address:  0xc0bCCbeB4091B525C50Bd75d10C7eB2161affA6a