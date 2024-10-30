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
          args: ["0xFB45f031943759FFa793aC19d0e47aE9723EbF9a"],
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
// deploying "DefaultProxyAdmin" (tx: 0xfd44d5b675f14ce8a958cc452f6b592d996690170095483d70b1c1bb0a6f8194)...: deployed at 0xDBb3388EA28b9135e05e5fC389Ce75f736249A7a with 643983 gas
// deploying "VeMetisMinter_Implementation" (tx: 0x9a4265a392505f090ac64013b248741a6451610a1c0d636c29ca3cba437b1ec0)...: deployed at 0x290Cf3a0CE36427caBFC58A750eBB57c684f3162 with 2455546 gas
// deploying "VeMetisMinter_Proxy" (tx: 0x28b7ece614eb3b6c29332fb2e709b8320fdad8eae4fbb7db43e385e5220d003b)...: deployed at 0xaF5f00Eb9418fa24a28B8CbF568C259D3678201f with 934567 gas
// ========Deploying VeMetisMinter========
// Contract address:  0xaF5f00Eb9418fa24a28B8CbF568C259D3678201f