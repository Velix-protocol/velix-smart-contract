# Velix Protocol

# Smart Contracts Documentation

This repository contains Solidity smart contracts managing protocol configurations, token redemption, reward distribution, and vault operations. Below is an overview of the key contracts and their functionalities.

---

## Config.sol

The `Config` contract centralizes protocol settings and role management.

### Key Functions:
- **`initialize()`**  
  Initializes the contract and assigns the deployer as the admin role.
  
- **`setInitialValues(address _metis, address _bridge, address _protocolTreasury, uint32 _protocolTreasuryRatio)`**  
  Sets initial protocol configuration values.

- **`setL1Dealer(address _l1Dealer)`**  
  Updates the address for the Layer 1 Dealer.

- **`protocolTreasuryRatio()`**  
  Retrieves the current protocol treasury ratio.

- **`hasRole(bytes32 role, address account)`**  
  Checks if an account has a specific role.

### Key Events:
- **`RoleGranted`**  
  Emitted when a role is granted to an account.  
- **`QueueLengthSecsSet`**  
  Emitted when the queue duration is updated.

---

## RedemptionQueue.sol

The `RedemptionQueue` contract manages `veMetis` token redemption through ERC721-based redemption tickets.

### Key Functions:
- **`enterRedemptionQueue(address _recipient, uint256 _amountToRedeem)`**  
  Allows a user to join the redemption queue and generates a redemption ticket (ERC721 token).

- **`redeemRedemptionTicketNft(uint256 _nftId, address _recipient)`**  
  Redeems an NFT for corresponding Metis tokens after the maturity period.

- **`getNftInformation(uint256 _nftId)`**  
  Fetches details of a specific redemption ticket.

### Key Events:
- **`EnterRedemptionQueue`**  
  Emitted when a user enters the redemption queue.  
- **`RedeemRedemptionTicketNft`**  
  Emitted when a ticket is redeemed for Metis tokens.

---

## RewardDispatcher.sol

The `RewardDispatcher` contract handles the distribution of rewards between the protocol treasury and the `VelixVault`.

### Key Functions:
- **`dispatch()`**  
  Splits available Metis tokens between the protocol treasury and the `VelixVault`.

### Key Events:
- **`Dispatched(uint256 amount, uint256 toTreasuryAmount, uint256 toVaultAmount)`**  
  Logs the details of reward distribution.

---

## VelixVault.sol

The `VelixVault` contract implements the ERC4626 vault standard for managing Metis token deposits and withdrawals.

### Key Functions:
- **`depositToL1Dealer(uint256 amount)`**  
  Sends Metis tokens from the vault to the Layer 1 Dealer via the bridge.

- **`addAssets(uint256 assets)`**  
  Adds Metis tokens to the vault's asset pool.

- **`_withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)`**  
  Handles token withdrawals and enters users into the redemption queue.

- **`sendMetisRewards(uint256 _amount)`**  
  Transfers Metis rewards from the vault to the `RewardDispatcher`.

### Key Events:
- **`AssetsAdded`**  
  Emitted when assets are added to the vault.  
- **`DepositToL1Dealer`**  
  Emitted when tokens are sent to the Layer 1 Dealer.  

---

## How to Use

1. **Deploy Contracts**  
   Deploy the contracts in the following order:
   - `Config`
   - `RewardDispatcher`
   - `VelixVault`
   - `RedemptionQueue`

2. **Configure Protocol Settings**  
   Use the `Config` contract to set the addresses and parameters for the protocol.

3. **Token Redemption**  
   - Redeem `veMetis` for Metis by entering the queue via `enterRedemptionQueue`.
   - Redeem tokens using `redeemRedemptionTicketNft` after maturity.

4. **Reward Dispatch**  
   Call the `dispatch` function in `RewardDispatcher` to allocate rewards.

5. **Vault Operations**  
   Deposit and withdraw Metis tokens via the `VelixVault`.