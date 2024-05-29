import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("VeMetisMinter", {
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
};

func.tags = ["VeMetisMinter"];

export default func;

// reusing "DefaultProxyAdmin" : 0x349f3de199C7FD5e4a1d756D2857B9Ca5f5F6576
// deploying "VeMetisMinter_Implementation":0xb97eb96BB8287fcdD5B1fddaeb31242a9602B474
// deploying "VeMetisMinter_Proxy": 0xb90F1deF3c13C05834E4d1B0A0F7612D60Cc70b4