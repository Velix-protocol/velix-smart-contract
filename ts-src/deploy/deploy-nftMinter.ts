import { ethers } from "./index";

async function main() {
  // Deploy NFTMinter contract
  console.log("Deploying NFTMinter contract");
  const NFTMinter = await ethers.getContractFactory("NFTMinter");
  const nftMinter = await NFTMinter.deploy();
  await nftMinter.waitForDeployment();
  console.log(" NFTMinter contract deployed at", nftMinter.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
// NFTMinter contract deployed at 0x5DBcfb13aC3aab5cCFD7d2c9b49b9017b7477EC8
