
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./Base.sol";
import "./interface/IVelixVault.sol";
import "./interface/IRedemptionQueue.sol";

/// @title RedemptionQueue
/// @notice RedemptionQueue is the contract that manages the redemption queue for veMetis
contract RedemptionQueue is Initializable, ERC721Upgradeable,IRedemptionQueue, Base {
    using SafeERC20 for IERC20;
    using SafeCast for *;

    uint64 nextNftId;

    /// @notice Information about a user's redemption ticket NFT
    mapping(uint256 nftId => RedemptionQueueItem) public nftInformation;

    IVelixVault public velixVault;
    IERC20 public METIS;


    function initialize(address _config) initializer public {
        __Base_init(_config);
        __ERC721_init("veMetisRedemptionTicket", "veMetis Redemption Ticket");
        METIS = IERC20(config.metis());
        velixVault = IVelixVault(config.velixVault());
    }

    // =============================================================================================
    // Configurations / Privileged functions
    // =============================================================================================

    // =============================================================================================
    // Queue Functions
    // =============================================================================================

    /// @notice Enter the queue for redeeming veMetis 1-to-1. Must approve first. Internal only so payor can be set
    /// @notice Will generate a veMetisRedemptionTicket NFT that can be redeemed for the actual Metis later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _amountToRedeem Amount of veMetis to redeem
    /// @param _nftId The ID of the veMetisRedemptionTicket NFT
    /// @dev Must call approve/permit on veMetis contract prior to this call
    function _enterRedemptionQueueCore(address _recipient, uint256 _amountToRedeem) internal returns (uint256 _nftId) {
        // Calculations: maturity timestamp
        uint64 _maturityTimestamp = uint64(block.timestamp) + config.queueLengthSecs();

        // Effects: Initialize the redemption ticket NFT information
        nftInformation[nextNftId] = RedemptionQueueItem({
            amount: _amountToRedeem,
            maturity: _maturityTimestamp,
            hasBeenRedeemed: false
        });

        // Effects: Mint the redemption ticket NFT. Make sure the recipient supports ERC721.
        _safeMint({ to: _recipient, tokenId: nextNftId });

        // Emit here, before the state change
        _nftId = nextNftId;
        emit EnterRedemptionQueue({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            amountVeMetisRedeemed: _amountToRedeem,
            maturityTimestamp: _maturityTimestamp
        });

        // Calculations: Increment the autoincrement
        ++nextNftId;
    }

    /// @notice Enter the queue for redeeming veMetis 1-to-1. Must approve or permit first.
    /// @notice Will generate a veMetisRedemptionTicket NFT that can be redeemed for the actual Metis later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _amountToRedeem Amount of veMetis to redeem
    /// @param _nftId The ID of the veMetisRedemptionTicket NFT
    /// @dev Must call approve/permit on veMetis contract prior to this call
    function enterRedemptionQueue(address _recipient, uint256 _amountToRedeem) public nonReentrant returns (uint256 _nftId) {
        require(_msgSender() == config.velixVault(), "RedemptionQueue: caller is not VelixVault");
        require(_recipient != address(0), "RedemptionQueue: zero address");
        require(_amountToRedeem > 0, "RedemptionQueue: amount is zero");

        // Do all of the NFT-generating and accounting logic
        _nftId = _enterRedemptionQueueCore(_recipient, _amountToRedeem);
    }


    /// @notice Redeems a veMetisRedemptionTicket NFT for Metis. (Pre-Metis send)
    /// @param _nftId The ID of the NFT
    /// @return _redemptionQueueItem The RedemptionQueueItem
    function _redeemRedemptionTicketNftPre(uint256 _nftId) internal returns (RedemptionQueueItem memory _redemptionQueueItem) {
        // Checks: ensure proper nft ownership
        if (!_isAuthorized({owner:ownerOf(_nftId), spender: msg.sender, tokenId: _nftId })) revert Erc721CallerNotOwnerOrApproved();

        // Get queue information
        _redemptionQueueItem = nftInformation[_nftId];

        // Checks: has been redeemed already
        if (_redemptionQueueItem.hasBeenRedeemed) {
            revert AlreadyRedeemed();
        }

        // Checks: Make sure maturity was reached
        if (block.timestamp < _redemptionQueueItem.maturity) {
            revert NotMatureYet({ currentTime: block.timestamp, maturity: _redemptionQueueItem.maturity });
        }

        // Effects: burn the Nft
        _burn(_nftId);
    
        // Effects: Mark nft as redeemed
        nftInformation[_nftId].hasBeenRedeemed = true;

    }

    /// @notice Redeems a veMetisRedemptionTicket NFT for Metis. Must have reached the maturity date first.
    /// @param _nftId The ID of the NFT
    /// @param _recipient The recipient of the redeemed Metis
    function redeemRedemptionTicketNft(uint256 _nftId, address _recipient) external virtual nonReentrant {
        require(_recipient != address(0), "RedemptionQueue: zero address");

        // Do everything except sending out the Metis back to the _recipient
        RedemptionQueueItem memory _redemptionQueueItem = _redeemRedemptionTicketNftPre(_nftId);

        // Interactions: Transfer Metis to recipient
        METIS.safeTransfer(_recipient, _redemptionQueueItem.amount);

        emit RedeemRedemptionTicketNft({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            amountOut: _redemptionQueueItem.amount
        });
    }

    function getNftId() external view returns (uint64) {
        return nextNftId;
    }

    function getNftInformation(uint256 _nftId) external view returns (RedemptionQueueItem memory) {
        return nftInformation[_nftId];
    }
    // ====================================
    // Errors
    // ====================================

    /// @notice ERC721: caller is not token owner or approved
    error Erc721CallerNotOwnerOrApproved();

    /// @notice NFT is not mature enough to redeem yet
    /// @param currentTime Current time.
    /// @param maturity Time of maturity
    error NotMatureYet(uint256 currentTime, uint64 maturity);
    
    /// @notice already redeemed
    error AlreadyRedeemed();

    function getMetisAddress()public view returns (address){
        return address(METIS);
    }
}