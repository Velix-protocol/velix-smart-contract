import { ethers, upgrades } from"./index";


async function main() {
    // Metis Toke: 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
    // bridge: 0x4200000000000000000000000000000000000010

    // Deploy VeMetisMinter contract and initialize it
    console.log("Deploying VeMetisMinter contract");
    const VeMetisMinter = await ethers.getContractFactory("VeMetisMinter");
    const veMetisMinter = await upgrades.deployProxy(VeMetisMinter, ["0xAe7b7Ab58EFbC82f15AC605744983202563Bce21"],{initializer:"initialize",});
    await veMetisMinter.waitForDeployment();
    console.log("VeMetisMinter contract deployed at",veMetisMinter.target);


}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

    // verify  --contract contracts/VeMetisMinter.sol:VeMetisMinter 0xfb23B1AC76c4932F9c28eCE33E26a5cAeaB58a9d
    // Verifying implementation: 0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6
    // Successfully submitted source code for contract
    // contracts/VeMetisMinter.sol:VeMetisMinter at 0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6
    // for verification on the block explorer. Waiting for verification result...
    
    // Successfully verified contract VeMetisMinter on the block explorer.
    // https://sepolia.explorer.metisdevops.link/address/0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6#code
    
    // Verifying proxy: 0xfb23B1AC76c4932F9c28eCE33E26a5cAeaB58a9d
    // Successfully verified contract TransparentUpgradeableProxy at 0xfb23B1AC76c4932F9c28eCE33E26a5cAeaB58a9d.
    // Linking proxy 0xfb23B1AC76c4932F9c28eCE33E26a5cAeaB58a9d with implementation