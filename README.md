# Velix Protocol Documentation

This documentation outlines the various contracts within the Velix Protocol, detailing their primary responsibilities and the purposes of their respective functions.

## All Contracts

### **Config**
**Description:** Manages configuration settings and roles for the protocol.

**Functions:**
- **`setConfig(address key, address value)`**
  - *Purpose:* Updates the configuration settings by associating a specific key with a new address value.
  
- **`getConfig(address key) view returns (address)`**
  - *Purpose:* Retrieves the address associated with a given configuration key.

- **`hasRole(bytes32 role, address account) view returns (bool)`**
  - *Purpose:* Checks if a particular account has been granted a specific role.

### **L1Dealer**
**Description:** Interacts with the LockingPool.

**Functions:**
- **`lockTokens(address user, uint256 amount)`**
  - *Purpose:* Locks a specified amount of tokens on behalf of a user within the LockingPool.

- **`unlockTokens(address user, uint256 amount)`**
  - *Purpose:* Unlocks a specified amount of tokens for a user from the LockingPool.

- **`getLockedAmount(address user) view returns (uint256)`**
  - *Purpose:* Retrieves the total amount of tokens locked by a specific user.

### **Metis**
**Description:** The smart contract address for the Metis token on the Sepolia testnet.

**Functions:**
- **`transfer(address to, uint256 amount) returns (bool)`**
  - *Purpose:* Transfers a specified amount of Metis tokens to a designated address.

- **`approve(address spender, uint256 amount) returns (bool)`**
  - *Purpose:* Grants approval to a spender to transfer up to a specified amount of Metis tokens on behalf of the token holder.

- **`balanceOf(address account) view returns (uint256)`**
  - *Purpose:* Retrieves the balance of Metis tokens held by a specific account.

### **ProtocolTreasure**
**Description:** The protocol's multisig wallet address.

**Functions:**
- **`deposit(uint256 amount)`**
  - *Purpose:* Allows authorized parties to deposit a specified amount of tokens into the multisig wallet.

- **`withdraw(address to, uint256 amount)`**
  - *Purpose:* Facilitates the withdrawal of a specified amount of tokens from the multisig wallet to a designated address.

- **`getBalance() view returns (uint256)`**
  - *Purpose:* Retrieves the current balance of tokens held in the multisig wallet.

### **RewardDispatcher**
**Description:** Initializes the contract by setting the configuration addresses.

**Functions:**
- **`initialize(address configAddress)`**
  - *Purpose:* Sets up the RewardDispatcher with the necessary configuration addresses during initialization.

- **`dispatchRewards(address user, uint256 amount)`**
  - *Purpose:* Distributes rewards to a specified user based on the amount calculated.

- **`updateRewardRate(uint256 newRate)`**
  - *Purpose:* Updates the rate at which rewards are distributed to users.

### **sveMetis**
**Description:** An upgradeable implementation of the ERC-4626 vault, allowing users to deposit `veMetis` tokens in exchange for `sveMetis` tokens and vice versa. It also distributes locking rewards to `sveMetis` token holders.

**Functions:**
- **`initialize(address config)`**
  - *Purpose:* Initializes the SveMetis contract with the provided configuration settings.

- **`deposit(uint256 assets, address receiver) returns (uint256 shares)`**
  - *Purpose:* Allows users to deposit a specified amount of `veMetis` tokens into the vault, receiving `sveMetis` tokens in return.

- **`withdraw(uint256 shares, address receiver, address owner) returns (uint256 assets)`**
  - *Purpose:* Enables users to withdraw their underlying `veMetis` tokens by burning their `sveMetis` shares.

- **`totalAssets() view returns (uint256)`**
  - *Purpose:* Returns the total amount of `veMetis` assets managed by the vault.

- **`harvestRewards()`**
  - *Purpose:* Distributes locking rewards to `sveMetis` token holders based on their shares.

### **veMetis**
**Description:** ERC-20 token representing the Metis token staked in the protocol.

**Functions:**
- **`transfer(address to, uint256 amount) returns (bool)`**
  - *Purpose:* Transfers a specified amount of veMetis tokens to a designated address.

- **`approve(address spender, uint256 amount) returns (bool)`**
  - *Purpose:* Grants approval to a spender to transfer up to a specified amount of veMetis tokens on behalf of the token holder.

- **`balanceOf(address account) view returns (uint256)`**
  - *Purpose:* Retrieves the balance of veMetis tokens held by a specific account.

### **veMetisMinter**
**Description:** Initializes the contract with configuration addresses and sets the initial deposit.

**Functions:**
- **`initialize(address config)`**
  - *Purpose:* Sets up the veMetisMinter with the necessary configuration addresses during initialization.

- **`depositToRedemptionQueue(uint256 amount)`**
  - *Purpose:* Deposits a specified amount of Metis tokens into the RedemptionQueue contract.

- **`redeemToTreasury(uint256 amount)`**
  - *Purpose:* Redeems a specified amount of veMetis tokens to the protocol treasury, ensuring sufficient Metis balance before burning and transferring tokens.

## RedemptionQueue Contract

### **Description**
The `RedemptionQueue` contract manages the redemption process for `veMetis` tokens by utilizing a queue system represented through ERC721 NFTs. This ensures that redemptions are handled in an orderly and secure manner.

### **Functions:**

- **`initialize(address _config)`**
  - *Purpose:* Initializes the RedemptionQueue contract with the provided configuration settings and sets up the METIS and veMetis token addresses.

- **`enterRedemptionQueue(address _recipient, uint120 _amountToRedeem) returns (uint256 _nftId)`**
  - *Purpose:* Allows users to enter the redemption queue by specifying a recipient and the amount of `veMetis` to redeem. This function mints a redemption ticket NFT representing the user's position in the queue.

- **`redeemRedemptionTicketNft(uint256 _nftId, address _recipient)`**
  - *Purpose:* Enables users to redeem their redemption ticket NFT for METIS tokens after the maturity period has been reached. This function burns the NFT and transfers the corresponding METIS amount to the recipient.

- **`getNftId() view returns (uint64)`**
  - *Purpose:* Retrieves the next available NFT ID for minting.

- **`getNftInformation(uint256 _nftId) view returns (RedemptionQueueItem memory)`**
  - *Purpose:* Provides detailed information about a specific redemption ticket NFT, including redemption status, amount, and maturity timestamp.

- **`getMetisAddress() view returns (address)`**
  - *Purpose:* Returns the address of the METIS token contract.

### **Internal Functions:**

- **`_enterRedemptionQueueCore(address _recipient, uint120 _amountToRedeem) returns (uint256 _nftId)`**
  - *Purpose:* Handles the core logic for entering the redemption queue, including calculating maturity timestamps, initializing NFT information, minting the NFT, and emitting the `EnterRedemptionQueue` event.

- **`_redeemRedemptionTicketNftPre(uint256 _nftId) returns (RedemptionQueueItem memory _redemptionQueueItem)`**
  - *Purpose:* Performs preliminary checks and state updates required before actually redeeming the NFT for METIS, such as verifying ownership, checking redemption status and maturity, burning the NFT, and burning the corresponding amount of veMetis.

## Error Handling

The contracts include robust error handling to ensure security and proper flow. Below are the custom errors defined within the contracts:

- **`Erc721CallerNotOwnerOrApproved()`**
  - *Thrown When:* Unauthorized addresses attempt NFT operations.

- **`ExceedsCollectedFees(uint128 collectAmount, uint128 accruedAmount)`**
  - *Thrown When:* Attempting to collect more fees than available.

- **`NotMatureYet(uint256 currentTime, uint64 maturity)`**
  - *Thrown When:* Redemption is attempted before maturity.

- **`AlreadyReducedMaturity()`**
  - *Thrown When:* Maturity has already been reduced.

- **`AlreadyRedeemed()`**
  - *Thrown When:* An NFT has already been redeemed.

## Conclusion

The Velix Protocol leverages a suite of smart contracts to manage token staking, redemption, and reward distribution effectively. Each contract plays a pivotal role in ensuring the protocol operates smoothly, offering users flexibility and security in their interactions.

For more detailed information on deploying, verifying, and migrating the contracts, please refer to the respective sections in the [README.md](./README.md).

## Deploy

```bash
npx hardhat --network metis-sepolia deploy --tags
```

## Verify

```bash
npx hardhat --network metis-sepolia etherscan-verify
```

## More

See the [migration guide](./migration.md)
