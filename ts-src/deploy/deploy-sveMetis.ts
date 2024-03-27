import { ethers, upgrades } from"./index";

async function main() {
    // Deploy SveMetis contract and initialize it
    console.log("Deploying SceMetis contract")
    const SveMetis = await ethers.getContractFactory("SveMetis");
    const sveMetis = await upgrades.deployProxy(SveMetis, ["0xF578812d6D648fc007365f780894A9c13DDd5f93"],{initializer:"initialize",});
    await sveMetis.waitForDeployment();
    console.log("SveMetis contract deployed at",sveMetis.target);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
