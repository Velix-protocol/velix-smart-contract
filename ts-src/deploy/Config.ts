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
// reusing "DefaultProxyAdmin" at 0x06E779a4332016a3b10C6C7331d74c422d2B2640
// deploying "Config_Implementation" (tx: 0x17902bca331963be2c095d4fd7c5dc53805e3ce3c81c142f906c39901beef03d)...: 
// deployed at 0x6E490944D482D1C3582174be32352080A8Ff7Cb7 with 3092036 gas
// executing DefaultProxyAdmin.upgrade (tx: 0xae7c1b003418e3fe6a7c1f7f37a75dd05b50f8003911e09552abdc87d0c4f55c) ...: performed with 38688 gas
// ========Deploying Config========
// Contract address:  0x4F84E5882E6ef2bA953f1A2C6594855EB38F4c91

//  address _metis, 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
//         address _bridge,0x4200000000000000000000000000000000000010
//         address _protocolTreasury,0xf42DBA76dCCff37777B98F4d42a99EAD20b57bDe
//         uint32 _protocolTreasuryRatio 100000 