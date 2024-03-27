import { ethers, upgrades } from "./index";

async function main() {
    // Deploy VeMetis contract and initialize it
    console.log("Deploying VeMetis contract");
    const VeMetis = await ethers.getContractFactory("VeMetis");
    const veMetis = await upgrades.deployProxy(VeMetis, ["0xF578812d6D648fc007365f780894A9c13DDd5f93"], { initializer: "initialize", });
    await veMetis.waitForDeployment();
    console.log("VeMetis contract deployed at", veMetis.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });