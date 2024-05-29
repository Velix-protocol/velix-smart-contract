import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("^^^========Deploying VeMetis========^^^");

  await deploy("VeMetis", {
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
  console.log("====xxxx====Deploying VeMetis====xxxx====");

};

func.tags = ["VeMetis"];

export default func;
// reusing "DefaultProxyAdmin" : 0x349f3de199C7FD5e4a1d756D2857B9Ca5f5F6576
// deploying "VeMetis_Implementation" : 0xc51D95684cC47C3CF151437654b192556809D993
// deploying "VeMetis_Proxy" : 0xF5db5bBEE03e99F509B036B1255C5080553E536c
