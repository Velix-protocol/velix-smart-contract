import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("^^^========Deploying SveMetis========^^^");

  await deploy("SveMetis", {
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
  console.log("====xxxx====Deploying SveMetis====xxxx====");

};

func.tags = ["SveMetis"];

export default func;
// reusing "DefaultProxyAdmin": 0x349f3de199C7FD5e4a1d756D2857B9Ca5f5F6576
// deploying "SveMetis_Implementation": 0x2Ce1016498535Dd66956Bfe1B107a60e88ED820a 
// deploying "SveMetis_Proxy": 0x50725560Ad9154C0765B422bA5a8D1E49c9F65aE