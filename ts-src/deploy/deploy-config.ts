import { ethers, upgrades } from "./index";

async function main() {
    // Metis Toke: 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
    // bridge: 0x4200000000000000000000000000000000000010
    // l1Dealer →(address) : 
    // protocolTreasury →(address) : 0x22558cFB47C05651d1350fcb29Ee79bED2C76278
    // protocolTreasuryRatio:1000


    // Deploy Config contract
    console.log("Deploying Config contract");
    const Config = await ethers.getContractFactory("Config");
    // Args: _metis,_bridge,_protocolTreasury,_protocolTreasuryRatio
    const config = await upgrades.deployProxy(Config, [], { initializer: "initialize" });
    await config.waitForDeployment();
    console.log(" Config contract deployed at", config.target);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
    
// Verifying implementation: 0x7D0537E6e1361B021d85D4513A33E3d832544A45
// Successfully submitted source code for contract
// contracts/Config.sol:Config at 0x7D0537E6e1361B021d85D4513A33E3d832544A45
// for verification on the block explorer. Waiting for verification result...

// Successfully verified contract Config on the block explorer.
// https://sepolia.explorer.metisdevops.link/address/0x7D0537E6e1361B021d85D4513A33E3d832544A45#code

// Verifying proxy: 0xAe7b7Ab58EFbC82f15AC605744983202563Bce21
// Contract at 0xAe7b7Ab58EFbC82f15AC605744983202563Bce21 already verified.
// Linking proxy 0xAe7b7Ab58EFbC82f15AC605744983202563Bce21 with implementation