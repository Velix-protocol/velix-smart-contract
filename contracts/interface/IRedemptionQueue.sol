// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRedemptionQueue {
    struct RedemptionQueueItem {
        bool hasBeenRedeemed;
        uint64 maturity;
        uint256 amount;
    }

    /// @notice The ```RedemptionQueueItem``` struct provides metadata information about each Nft
    /// @param hasBeenRedeemed boolean for whether the NFT has been redeemed
    /// @param amount How much Metis is claimable
    /// @param maturity Unix timestamp when they can claim their Metis
    struct RedemptionQueueAccounting {
        uint128 etherLiabilities;
        uint128 unclaimedFees;
    }

    event RedeemRedemptionTicketNft(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint256 amountOut
    );

    event EnterRedemptionQueue(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint256 amountVeMetisRedeemed,
        uint256 maturityTimestamp
    );

    function enterRedemptionQueue(
        address _recipient,
        uint256 _amountToRedeem
    ) external returns (uint256 _nftId);

    function redeemRedemptionTicketNft(
        uint256 _nftId,
        address _recipient
    ) external;

    function getNftId() external view returns (uint64);

    function getNftInformation(
        uint256 _nftId
    ) external view returns (RedemptionQueueItem memory);

    function getMetisAddress() external view returns (address);
}
