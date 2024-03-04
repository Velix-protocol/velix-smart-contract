import { ethers, upgrades } from"./index";

async function main() {
    // Deploy VeMetis contract and initialize it
    console.log("Deploying VeMetis contract");
    const VeMetis = await ethers.getContractFactory("VeMetis");
    const veMetis = await upgrades.deployProxy(VeMetis, ["0xAe7b7Ab58EFbC82f15AC605744983202563Bce21"],{initializer:"initialize",});
    await veMetis.waitForDeployment();
    console.log("VeMetis contract deployed at",veMetis.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
    // Verifying implementation: 0xeDfaAA74546f60E7F1Fa09D25399cAcebE75B87D
    // The contract 0xeDfaAA74546f60E7F1Fa09D25399cAcebE75B87D has already been verified on Etherscan.
    // https://sepolia.explorer.metisdevops.link/address/0xeDfaAA74546f60E7F1Fa09D25399cAcebE75B87D#code
    // Verifying proxy: 0x51B1C28f55d2Aed036deEe294Ce105f3952321bB
    // Successfully verified contract TransparentUpgradeableProxy at 0x51B1C28f55d2Aed036deEe294Ce105f3952321bB.
    // Linking proxy 0x51B1C28f55d2Aed036deEe294Ce105f3952321bB with implementation