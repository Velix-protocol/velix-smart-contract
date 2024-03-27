import { ethers, upgrades } from"./index";


async function main() {

    // Deploy RewardDispatcher contract and initialize it
    console.log("Deploying RewardDispatcher contract");
    const RewardDispatcher = await ethers.getContractFactory("RewardDispatcher");
    const rewardDispatcher = await upgrades.deployProxy(RewardDispatcher, ["0xF578812d6D648fc007365f780894A9c13DDd5f93"],{initializer:"initialize",});
    await rewardDispatcher.waitForDeployment();
    console.log("RewardDispatcher contract deployed at",rewardDispatcher.target);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
