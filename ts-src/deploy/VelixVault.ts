import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying VelixVault");
  const result = await deploy("VelixVault", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: ["0xFB6E65f3d6207f326A6B88830b1E35c1F98BF25d"],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
  console.log("========Deploying VelixVault========");
  console.log("Contract address: ", result.address);
};

func.tags = ["VelixVault"];

export default func;
// ========Deploying VelixVault========
// Contract address:  0xE8D82024A98D4A62780F5f52f74E02bCc3bEb5bc