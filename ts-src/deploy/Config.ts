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
// Config_Implementation(0xd37dd532ec56973693d507068107604471f3535c);
// Config_Proxy (0xFB45f031943759FFa793aC19d0e47aE9723EbF9a), skipping.
// DefaultProxyAdmin (0x9522454B069f510a73Ab7179C8826Fc917514DF3)

//  address _metis, 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
//         address _bridge,0x4200000000000000000000000000000000000010
//         address _protocolTreasury,0xf42DBA76dCCff37777B98F4d42a99EAD20b57bDe
//         uint32 _protocolTreasuryRatio 100000 