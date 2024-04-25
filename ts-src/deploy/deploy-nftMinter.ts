import { ethers, upgrades } from "./index";

async function main() {
    // Deploy NFTMinter contract
    console.log("Deploying NFTMinter contract");
    const NFTMinter = await ethers.getContractFactory("NFTMinter");
    
    const nftMinter = await upgrades.deployProxy(NFTMinter, [], { initializer: "initialize" });
    await nftMinter.waitForDeployment();
    console.log(" nfTMinter contract deployed at", nftMinter.target);
  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

  // nfTMinter contract deployed at 0xfe2bbF579004E10926c925001068CA3E6FCE90DC