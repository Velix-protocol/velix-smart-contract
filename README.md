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


# RedemptionQueue Contract

## Introduction

The `RedemptionQueue` contract manages the redemption process for `veMetis` tokens by utilizing a queue system represented through ERC721 NFTs. This ensures that redemptions are handled in an orderly and secure manner. This README provides an overview of the redemption flow, detailing the steps users take to redeem their `veMetis` for `METIS`, as well as additional functionalities available within the contract.

## Redemption Flow

The following outlines the user flow for redeeming `veMetis` tokens using the `RedemptionQueue` contract:

### 1. Entering the Redemption Queue

#### **Function Involved**
- `enterRedemptionQueue`

#### **Steps:**

1. **Approval:**
   - The user must first approve the `RedemptionQueue` contract to transfer the desired amount of `veMetis` tokens on their behalf. This can be done by calling the `approve` or `permit` function on the `veMetis` contract.

2. **Initiate Redemption:**
   - The user calls the `enterRedemptionQueue` function, specifying the recipient address and the amount of `veMetis` they wish to redeem.
   - **Example:**
     ```solidity
     redemptionQueue.enterRedemptionQueue(recipientAddress, amountToRedeem);
     ```

3. **Token Transfer & NFT Minting:**
   - Upon successful execution, the specified amount of `veMetis` is transferred from the user to the `RedemptionQueue` contract.
   - An ERC721 NFT (`veMetisRedemptionTicket`) is minted to the recipient, representing their position in the redemption queue.
   - The NFT contains metadata such as the redemption amount, maturity timestamp, and associated fees.

4. **Event Emitted:**
   - `EnterRedemptionQueue` event is emitted, detailing the NFT ID, sender, recipient, amount redeemed, fees, and maturity timestamp.

#### **Outcome:**
- The user now holds an NFT that represents their claim to redeem `veMetis` for `METIS` after a specified maturity period.

### 2. Waiting for Maturity

#### **Details:**
- Each redemption ticket NFT has a `maturity` timestamp.
- The user must wait until the current block timestamp surpasses the `maturity` time to proceed with redemption.

### 3. Redeeming the NFT for METIS

#### **Function Involved**
- `redeemRedemptionTicketNft`

#### **Steps:**

1. **Ensure Maturity:**
   - The user verifies that the current time is past the `maturity` timestamp associated with their NFT.

2. **Initiate Redemption:**
   - The user calls the `redeemRedemptionTicketNft` function, providing the NFT ID and the recipient address.
   - **Example:**
     ```solidity
     redemptionQueue.redeemRedemptionTicketNft(nftId, recipientAddress);
     ```

3. **Burning & Token Transfer:**
   - The NFT is burned, marking the redemption as completed.
   - The corresponding amount of `METIS` is transferred to the recipient.

4. **Event Emitted:**
   - `RedeemRedemptionTicketNft` event is emitted, detailing the NFT ID, sender, recipient, and amount redeemed.

#### **Outcome:**
- The user receives the specified amount of `METIS` tokens.

### 4. Optional: Canceling the Redemption

#### **Function Involved**
- `cancelRedemptionTicketNft`

#### **Steps:**

1. **Initiate Cancellation:**
   - Before the `maturity` timestamp, the user can choose to cancel their redemption by calling the `cancelRedemptionTicketNft` function with the NFT ID and recipient address.
   - **Example:**
     ```solidity
     redemptionQueue.cancelRedemptionTicketNft(nftId, recipientAddress);
     ```

2. **Fee Assessment:**
   - A cancellation fee (`cancelRedemptionFee`) is calculated based on the redemption amount.
   - The fee is deducted from the redeemed amount.

3. **Token Transfers & NFT Burning:**
   - The remaining `veMetis` is transferred back to the user after deducting the fee.
   - The NFT is burned, marking the redemption as canceled.

4. **Event Emitted:**
   - `CancelRedemptionTicketNft` event is emitted, detailing the NFT ID, sender, recipient, amount returned, and cancellation fee.

#### **Outcome:**
- The user retrieves their `veMetis` minus the cancellation fee, and the redemption queue position is revoked.

### 5. Optional: Reducing Redemption Maturity

#### **Function Involved**
- `reduceRedemptionMaturity`

#### **Steps:**

1. **Provide LP Tokens:**
   - The user can reduce the waiting period (`maturity`) by providing Liquidity Provider (LP) tokens.
   - They must specify the NFT ID, LP token address, and the amount of LP tokens to lock.

2. **Initiate Reduction:**
   - Call the `reduceRedemptionMaturity` function with the necessary parameters.
   - **Example:**
     ```solidity
     redemptionQueue.reduceRedemptionMaturity(nftId, lpTokenAddress, lpAmount);
     ```

3. **Maturity Adjustment:**
   - The `maturity` timestamp is reduced based on the provided LP tokens and predefined factors.
   - The LP tokens are locked in the contract until a specific lock maturity timestamp.

4. **Event Emitted:**
   - `ReduceRedemptionMaturity` event is emitted, detailing the NFT ID, LP token details, reduced time, and new maturity timestamp.

#### **Outcome:**
- The user can redeem their `METIS` earlier by locking up LP tokens, enhancing flexibility in managing their redemption.

### 6. Optional: Unlocking LP Tokens

#### **Function Involved**
- `unlockLpToken`

#### **Steps:**

1. **Wait for LP Lock Maturity:**
   - After reducing the maturity, the LP tokens are locked for a specified duration (`reduceMaturityStakeSecs`).

2. **Initiate Unlock:**
   - Once the lock period has passed, the user can call the `unlockLpToken` function with their NFT ID.
   - **Example:**
     ```solidity
     redemptionQueue.unlockLpToken(nftId);
     ```

3. **LP Token Transfer:**
   - The locked LP tokens are transferred back to the user.
   - The NFT is burned if there are no remaining redemption claims.

4. **Event Emitted:**
   - `UnlockLpToken` event is emitted, detailing the NFT ID and LP token details.

#### **Outcome:**
- The user retrieves their locked LP tokens after the lock period, completing the reduced maturity process.

### 7. Collecting Redemption Fees

#### **Function Involved**
- `collectRedemptionFees`

#### **Steps:**

1. **Initiate Collection:**
   - Authorized roles (`TimeLock` or `Admin`) can call `collectRedemptionFees` to withdraw accrued redemption fees.

2. **Fee Transfer:**
   - The specified fee amount is transferred to the protocol's treasury.

3. **Event Emitted:**
   - `CollectRedemptionFees` event is emitted, detailing the recipient and the amount collected.

#### **Outcome:**
- The protocol efficiently manages and collects fees generated from redemptions.

## Summary of Events

- **`EnterRedemptionQueue`**: Emitted when a user enters the redemption queue by minting an NFT.
- **`RedeemRedemptionTicketNft`**: Emitted upon successful redemption of the NFT for `METIS`.
- **`CancelRedemptionTicketNft`**: Emitted when a user cancels their redemption, detailing the fees incurred.
- **`ReduceRedemptionMaturity`**: Emitted when a user reduces the redemption waiting period using LP tokens.
- **`UnlockLpToken`**: Emitted when LP tokens are unlocked and returned to the user.
- **`CollectRedemptionFees`**: Emitted when the protocol collects redemption fees.

## Error Handling

The contract includes robust error handling to ensure security and proper flow:

- **`Erc721CallerNotOwnerOrApproved`**: Thrown when unauthorized addresses attempt NFT operations.
- **`ExceedsCollectedFees`**: Thrown when attempting to collect more fees than available.
- **`NotMatureYet`**: Thrown when redemption is attempted before maturity.
- **`AlreadyReducedMaturity`**: Thrown if maturity has already been reduced.
- **`LpTokenNotLocked`**: Thrown when LP tokens are not locked but an unlock is attempted.
- **`ReduceTimeExceedsLimit`**: Thrown if the requested time reduction exceeds allowed limits.
- **`AlreadyRedeemed`**: Thrown if an NFT has already been redeemed.

## Conclusion

The `RedemptionQueue` contract provides a structured and secure method for users to redeem their `veMetis` tokens for `METIS`. By leveraging ERC721 NFTs to represent redemption positions, the contract ensures transparency and flexibility. Users can manage their redemptions proactively by utilizing optional features like reducing maturity periods with LP tokens, enhancing their control over the redemption process.


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
