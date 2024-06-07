# Velix  Protocol

This is an LSD protocol built on Metis network, it implements a dual token mechanism
and uses the ERC-4626 standard for it's vault contract called sveMetis.

Check out the documentation linked bellow for more information
[Velix Docs](https://ceg.vote/t/lst-protocol-proposal-velix/3403)

# All contract  

- Config: Manages configuration settings and roles for the protocol.
- L1Dealer: Calls LockingPool through SequencerAgent
- Metis:  The smart contract address for the Metis token sepolia testnet.
- ProtocolTreasure: The protocol's mutlisig wallet address
- RewardDispatcher: Initializes the contract by setting the configuration addresses.
- sveMETIS:  The SveMetis contract is an implementation of the ERC4626 vault.
- veMETIS: ERC-20 token represnting the Metis token staked in the protocol.
- veMentisMinter: Initializes the contract with configuration addresses and sets initial deposit.

## Deploy

```
npx hardhat --network metis-sepolia deploy --tags
```

## Verify

```
npx hardhat --network metis-sepolia etherscan-verify
```

## More

See the [migration guide](./migration.md)
