
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./Base.sol";
import "./interface/IVeMetis.sol";

/// @title RedemptionQueue
/// @notice RedemptionQueue is the contract that manages the redemption queue for veMetis
contract RedemptionQueue is Initializable, ERC721Upgradeable, Base {
    using SafeERC20 for IERC20;
    using SafeCast for *;

    /// @notice The ```RedemptionQueueItem``` struct provides metadata information about each Nft
    /// @param hasBeenRedeemed boolean for whether the NFT has been redeemed
    /// @param amount How much Metis is claimable
    /// @param maturity Unix timestamp when they can claim their Metis
    struct RedemptionQueueItem {
        bool hasBeenRedeemed;
        uint64 maturity;
        uint120 amount;
    }

    /// @param etherLiabilities How much Metis would need to be paid out if every NFT holder could claim immediately
    /// @param unclaimedFees Earned fees that the protocol has not collected yet
    struct RedemptionQueueAccounting {
        uint128 etherLiabilities;
        uint128 unclaimedFees;
    }

    uint64 nextNftId;

    /// @notice Accounting redemption queue
    RedemptionQueueAccounting public redemptionQueueAccounting;

    /// @notice Information about a user's redemption ticket NFT
    mapping(uint256 nftId => RedemptionQueueItem) public nftInformation;

    IERC20 public veMetis;
    IERC20 public METIS;
    
    /// @notice When someone redeems their NFT for Metis
    /// @param nftId the if of the nft redeemed
    /// @param sender the msg.sender
    /// @param recipient the recipient of the ether
    /// @param amountOut the amount of ether sent to the recipient
    event RedeemRedemptionTicketNft(uint256 indexed nftId, address indexed sender, address indexed recipient,  uint120 amountOut);

    /// @notice When someone enters the redemption queue
    /// @param nftId The ID of the NFT
    /// @param sender The address of the msg.sender, who is redeeming veMetis
    /// @param recipient The recipient of the NFT
    /// @param amountVeMetisRedeemed The amount of veMetis redeemed
    event EnterRedemptionQueue(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint256 amountVeMetisRedeemed,
        uint256 maturityTimestamp
    );

    function initialize(address _config) initializer public {
        __Base_init(_config);
        __ERC721_init("veMetisRedemptionTicket", "veMetis Redemption Ticket");
        METIS = IERC20(config.metis());
        veMetis = IERC20(config.veMetis());
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
    function _enterRedemptionQueueCore(address _recipient, uint120 _amountToRedeem) internal returns (uint256 _nftId) {
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
    function enterRedemptionQueue(address _recipient, uint120 _amountToRedeem) public nonReentrant returns (uint256 _nftId) {
        require(_recipient != address(0), "RedemptionQueue: zero address");
        require(_amountToRedeem > 0, "RedemptionQueue: amount is zero");

        // Do all of the NFT-generating and accounting logic
        _nftId = _enterRedemptionQueueCore(_recipient, _amountToRedeem);

        // Interactions: Transfer veMetis in from the sender
        veMetis.safeTransferFrom({ from: msg.sender, to: address(this), value: _amountToRedeem });
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

        // Effects: Burn veMetis to match the amount of ether sent to user 1:1          
        IVeMetis(config.veMetis()).burn(address(this), _redemptionQueueItem.amount);
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

    /// @notice When timelock/operator tries collecting more fees than they are due
    /// @param collectAmount How much fee the ounsender is trying to collect
    /// @param accruedAmount How much fees are actually collectable
    error ExceedsCollectedFees(uint128 collectAmount, uint128 accruedAmount);

    /// @notice NFT is not mature enough to redeem yet
    /// @param currentTime Current time.
    /// @param maturity Time of maturity
    error NotMatureYet(uint256 currentTime, uint64 maturity);

    /// @notice Already reduced maturity
    error AlreadyReducedMaturity();
    
    /// @notice already redeemed
    error AlreadyRedeemed();

    function getMetisAddress()public view returns (address){
        return address(METIS);
    }
}