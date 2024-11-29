import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  getNamedAccounts,
  deployments,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying Config");
  const result = await deploy("Config", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [],
        },
      },
    },
    waitConfirmations: 1,
    log: true,
  });
  console.log("========Deploying Config========");
  console.log("Contract address: ", result.address);
};

func.tags = ["Config"];

export default func;
// Deploying Config
// ========Deploying Config========
// Contract address:  0xFB6E65f3d6207f326A6B88830b1E35c1F98BF25d

// ==========initial values ================
//  address _metis, 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
//  address _bridge,0x4200000000000000000000000000000000000010
//  address _protocolTreasury,0xf42DBA76dCCff37777B98F4d42a99EAD20b57bDe
//  uint32 _protocolTreasuryRatio 100000 