import { ethers, upgrades } from"./index";

async function main() {
    // Deploy SveMetis contract and initialize it
    console.log("Deploying SceMetis contract")
    const SveMetis = await ethers.getContractFactory("SveMetis");
    const sveMetis = await upgrades.deployProxy(SveMetis, ["0xAe7b7Ab58EFbC82f15AC605744983202563Bce21"],{initializer:"initialize",});
    await sveMetis.waitForDeployment();
    console.log("SveMetis contract deployed at",sveMetis.target);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Verifying implementation: 0xcc830E09Ce867153B8e2ac12F875D68571d4bcC8
// Successfully submitted source code for contract
// contracts/SveMetis.sol:SveMetis at 0xcc830E09Ce867153B8e2ac12F875D68571d4bcC8
// for verification on the block explorer. Waiting for verification result...

// Successfully verified contract SveMetis on the block explorer.
// https://sepolia.explorer.metisdevops.link/address/0xcc830E09Ce867153B8e2ac12F875D68571d4bcC8#code

// Verifying proxy: 0xc9D0D4a8F290FccAAaF6390455ab10A3a64128Ad
// Contract at 0xc9D0D4a8F290FccAAaF6390455ab10A3a64128Ad already verified.
// Linking proxy 0xc9D0D4a8F290FccAAaF6390455ab10A3a64128Ad with implementation