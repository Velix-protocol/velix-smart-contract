import { ethers, upgrades } from"./index";


async function main() {
    // Metis Toke: 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000
    // bridge: 0x4200000000000000000000000000000000000010

    // Deploy RewardDispatcher contract and initialize it
    console.log("Deploying RewardDispatcher contract");
    const RewardDispatcher = await ethers.getContractFactory("RewardDispatcher");
    const rewardDispatcher = await upgrades.deployProxy(RewardDispatcher, ["0xAe7b7Ab58EFbC82f15AC605744983202563Bce21"],{initializer:"initialize",});
    await rewardDispatcher.waitForDeployment();
    console.log("RewardDispatcher contract deployed at",rewardDispatcher.target);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

//  verify  --contract contracts/RewardDispatcher.sol:RewardDispatcher 0xbC56d2dcb02B4836A3Ea8D2350f2196B903BF8BB
// Verifying implementation: 0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6
// The contract 0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6 has already been verified on Etherscan.
// https://sepolia.explorer.metisdevops.link/address/0x5653a926668ff75B38c815cf3Fb0Fb6b9d4CEFE6#code
// Verifying proxy: 0xbC56d2dcb02B4836A3Ea8D2350f2196B903BF8BB
// Successfully verified contract TransparentUpgradeableProxy at 0xbC56d2dcb02B4836A3Ea8D2350f2196B903BF8BB.
// Linking proxy 0xbC56d2dcb02B4836A3Ea8D2350f2196B903BF8BB with implementation