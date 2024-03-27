import { ethers, upgrades } from"./index";


async function main() {
    // Deploy VeMetisMinter contract and initialize it
    console.log("Deploying VeMetisMinter contract");
    const VeMetisMinter = await ethers.getContractFactory("VeMetisMinter");
    const veMetisMinter = await upgrades.deployProxy(VeMetisMinter, ["0xF578812d6D648fc007365f780894A9c13DDd5f93"],{initializer:"initialize",});
    await veMetisMinter.waitForDeployment();
    console.log("VeMetisMinter contract deployed at",veMetisMinter.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
