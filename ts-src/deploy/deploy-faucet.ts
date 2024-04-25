import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "./index";

async function main() {
  // Deploy Faucet contract
  console.log("Deploying Faucet contract");
  const Faucet = await ethers.getContractFactory("Faucet");
  const faucet = await Faucet.deploy();
  await faucet.waitForDeployment();
  console.log(" Faucet contract deployed at", faucet.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
