import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying VeMetisMinter");
  const result = await deploy("VeMetisMinter", {
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
  console.log("========Deploying VeMetisMinter========");
  console.log("Contract address: ", result.address);
};

func.tags = ["VeMetisMinter"];

export default func;
// Deploying VeMetisMinter
// reusing "DefaultProxyAdmin" at 0x06E779a4332016a3b10C6C7331d74c422d2B2640
// deploying "VeMetisMinter_Implementation" (tx: 0xeaf9510046d0e201449e79aab67a50827f9c348d90f0513aca6cd7dd87d962c4)...: deployed at 0x108DC45Faeaa096aC7549e1a73F247Fb0c8DDaD4 with 2409854 gas
// deploying "VeMetisMinter_Proxy" (tx: 0x1f7cfb2bd77ee0f590228cd79c3f2ef2d849bc6ba5ed76438bd302687fd49f95)...: deployed at 0x82c6D49F563D87F8D95bDd7350174d0314401B18 with 882091 gas
// ========Deploying VeMetisMinter========
// Contract address:  0x82c6D49F563D87F8D95bDd7350174d0314401B18