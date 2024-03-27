import { ethers, upgrades } from"./index";

async function main() {
    // Upgrade SveMetis contract and initialize it
    console.log("Upgrading SceMetis contract")
    const SveMetis = await ethers.getContractFactory("SveMetisV2");
    await upgrades.upgradeProxy("0xc9D0D4a8F290FccAAaF6390455ab10A3a64128Ad",SveMetis, {initializer:"initialize",});
    console.log("SveMetis upgraded");

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

    // 0xc9D0D4a8F290FccAAaF6390455ab10A3a64128Ad