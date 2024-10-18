// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./Base.sol";
import "./interface/IVeMetis.sol";

/// @title RedemptionQueue
/// @notice RedemptionQueue is the contract that manages the redemption queue for veMetis
contract RedemptionQueue is ERC721Upgradeable, Base {
    using SafeERC20 for IERC20;
    using SafeCast for *;

    /// @notice The ```RedemptionQueueItem``` struct provides metadata information about each Nft
    /// @param hasBeenRedeemed boolean for whether the NFT has been redeemed
    /// @param amount How much Metis is claimable
    /// @param maturity Unix timestamp when they can claim their Metis
    /// @param cancelRedemptionFee cancellation fee
    struct RedemptionQueueItem {
        bool hasBeenRedeemed;
        uint64 maturity;
        uint120 amount;
        uint64 cancelRedemptionFee;
        uint64 lpLockMaturity;
        address lpLockToken;
        uint256 lpLockAmount;
        bool lpClaimed;
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
    
    /// @notice lpFactor = lpPrice * reduceMaturityStakeSecs / MetisPrice
    mapping(address => uint256) public lpFactors;

    function initialize(address _config) initializer public {
        // __Base_init(_config, _holdTokens);
        __Base_init(_config);
        __ERC721_init("veMetisRedemptionTicket", "veMetis Redemption Queue Ticket");
        METIS = IERC20(config.metis());
        veMetis = IERC20(config.veMetis());
    }

    // =============================================================================================
    // Configurations / Privileged functions
    // =============================================================================================

    /// @notice When the accrued redemption fees are collected
    /// @param recipient The address to receive the fees
    /// @param collectAmount Amount of fees collected
    event CollectRedemptionFees(address recipient, uint128 collectAmount);

    /// @notice Collect redemption feesTIMELOCK_ROLE
    /// @param _collectAmount Amount of veMetis to collect
    function collectRedemptionFees(uint128 _collectAmount) external onlyTimeLockOrAdmin {
        require(_collectAmount > 0, "RedemptionQueue: amount is zero");

        uint128 _unclaimedFees = redemptionQueueAccounting.unclaimedFees;

        // Make sure you are not taking too much
        if (_collectAmount > _unclaimedFees) revert ExceedsCollectedFees(_collectAmount, _unclaimedFees);

        // Decrement the unclaimed fee amount
        redemptionQueueAccounting.unclaimedFees -= _collectAmount;

        address feeRecipient = config.protocolTreasury();

        // Interactions: Transfer veMetis fees to the recipient
        veMetis.safeTransfer({ to: feeRecipient, value: _collectAmount });

        emit CollectRedemptionFees({ recipient: feeRecipient, collectAmount: _collectAmount });
    }

    /// @notice set lp factor
    function setLpFactor(address lpToken, uint256 factor) external onlyBackend {
        require(lpToken != address(0), "RedemptionQueue: zero address");
        lpFactors[lpToken] = factor;
    }

    // =============================================================================================
    // Queue Functions
    // =============================================================================================

    /// @notice Estimate the amount of LP token needed to reduce maturity specific amount of veMetis and reduce time
    /// @param lpToken lp token address
    /// @param reduceTime reduce time
    /// @param redeemAmount redeem amount
    /// @return lpAmount LP token amount
    /// @return amount0 amount0
    /// @return amount1 amount1
    function estimateLpAmount(address lpToken, uint64 reduceTime, uint256 redeemAmount) external view returns (uint256 lpAmount, uint256 amount0, uint256 amount1) {
        lpAmount = redeemAmount * reduceTime / lpFactors[lpToken];
        (bool success, bytes memory returnData) = lpToken.staticcall(abi.encodeWithSignature("getReserves()"));
        require(success, "RedemptionQueue: getReserves failed");
        (uint112 reserve0, uint112 reserve1, ) = abi.decode(returnData, (uint112, uint112, uint32));
        uint256 totalSupply = IERC20(lpToken).totalSupply();
        amount0 = lpAmount * reserve0 / totalSupply;
        amount1 = lpAmount * reserve1 / totalSupply;
    }

    /// @notice Estimate the reduce time
    /// @param lpToken LP token address
    /// @param lpAmount LP token amount
    /// @param redeemAmount redeem amount
    function getReduceTime(address lpToken, uint256 lpAmount, uint256 redeemAmount) public view returns (uint64) {
        return uint64(lpFactors[lpToken] * lpAmount / redeemAmount);
    }

    /// @notice When someone enters the redemption queue
    /// @param nftId The ID of the NFT
    /// @param sender The address of the msg.sender, who is redeeming veMetis
    /// @param recipient The recipient of the NFT
    /// @param amountEMetisRedeemed The amount of veMetis redeemed
    /// @param maturityTimestamp The date of maturity, upon which redemption is allowed
    /// @param redemptionFeeAmount The redemption fee
    /// @param cancelRedemptionFee The fee to cancel the redemption
    event EnterRedemptionQueue(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint256 amountEMetisRedeemed,
        uint120 redemptionFeeAmount,
        uint64 maturityTimestamp,
        uint256 cancelRedemptionFee 
    );

    /// @notice Enter the queue for redeeming veMetis 1-to-1. Must approve first. Internal only so payor can be set
    /// @notice Will generate a veMetisRedemptionTicket NFT that can be redeemed for the actual Metis later.
    /// @param _recipient Recipient of the NFT. Must be ERC721 compatible if a contract
    /// @param _amountToRedeem Amount of veMetis to redeem
    /// @param _nftId The ID of the veMetisRedemptionTicket NFT
    /// @dev Must call approve/permit on veMetis contract prior to this call
    function _enterRedemptionQueueCore(address _recipient, uint120 _amountToRedeem) internal returns (uint256 _nftId) {
        // Get queue information
        RedemptionQueueAccounting memory _redemptionQueueAccounting = redemptionQueueAccounting;

        // Calculations: redemption fee
        uint120 _redemptionFeeAmount = ((uint256(_amountToRedeem) * config.redemptionFee()) /
            FEE_PRECISION).toUint120();

        // Calculations: amount of Metis owed to the user
        uint120 _amountMetisOwedToUser = _amountToRedeem - _redemptionFeeAmount;

        // Calculations: increment ether liabilities by the amount of ether owed to the user
        _redemptionQueueAccounting.etherLiabilities += uint128(_amountMetisOwedToUser);

        // Calculations: increment unclaimed fees by the redemption fee taken
        _redemptionQueueAccounting.unclaimedFees += _redemptionFeeAmount;

        // Calculations: maturity timestamp
        uint64 _maturityTimestamp = uint64(block.timestamp) + config.queueLengthSecs();

        // Effects: Initialize the redemption ticket NFT information
        nftInformation[nextNftId] = RedemptionQueueItem({
            amount: _amountMetisOwedToUser,
            maturity: _maturityTimestamp,
            hasBeenRedeemed: false,
            cancelRedemptionFee: config.cancelRedemptionFee(),
            lpLockMaturity: 0,
            lpLockToken: address(0),
            lpLockAmount: 0,
            lpClaimed: false
        });

        // Effects: Mint the redemption ticket NFT. Make sure the recipient supports ERC721.
        _safeMint({ to: _recipient, tokenId: nextNftId });

        // Emit here, before the state change
        _nftId = nextNftId;
        emit EnterRedemptionQueue({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            amountEMetisRedeemed: _amountToRedeem,
            redemptionFeeAmount: _redemptionFeeAmount,
            maturityTimestamp: _maturityTimestamp,
            cancelRedemptionFee: config.cancelRedemptionFee()
        });

        // Calculations: Increment the autoincrement
        ++nextNftId;

        // Effects: Write all of the accounting changes to storage
        redemptionQueueAccounting = _redemptionQueueAccounting;
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

    /// @notice When someone cancel their NFT for veMetis, with the penalty
    /// @param nftId The ID of the NFT
    /// @param sender The sender of the NFT
    /// @param recipient The recipient of the redeemed Metis
    /// @param veMetisOut The amount of veMetis actually sent back to the user
    /// @param cancelRedemptionFee The fee to cancel the redemption
    event CancelRedemptionTicketNft(
        uint256 indexed nftId,
        address indexed sender,
        address indexed recipient,
        uint120 veMetisOut,
        uint120 cancelRedemptionFee
    );

    /// @notice Cancels a veMetisRedemptionTicket. Is penalized in doing so. Used if person does not want to wait for exit anymore.
    /// @param _nftId The ID of the NFT
    /// @param _recipient The recipient of the redeemed Metis
    /// @return _veMetisOut The amount of veMetis actually sent back to the user
    function cancelRedemptionTicketNft(
        address _recipient,
        uint256 _nftId
    ) external nonReentrant returns (uint120 _veMetisOut) {
        require(_recipient != address(0), "RedemptionQueue: zero address");

        // Checks: ensure proper nft ownership
        if (!_isAuthorized({owner:ownerOf(_nftId), spender: msg.sender, tokenId: _nftId })) revert Erc721CallerNotOwnerOrApproved();

        // Get data from state for use in calculations
        RedemptionQueueAccounting memory _redemptionQueueAccounting = redemptionQueueAccounting;
        RedemptionQueueItem memory _redemptionQueueItem = nftInformation[_nftId];
        uint120 _amountToRedeem = _redemptionQueueItem.amount;

        // Checks: has been redeemed already
        if (_redemptionQueueItem.hasBeenRedeemed) {
            revert AlreadyRedeemed();
        }

        // Calculations: remove owed ether from the liabilities
        _redemptionQueueAccounting.etherLiabilities -= _amountToRedeem;

        // Calculations: determine the cancel exit fee
        uint120 _cancelRedemptionFee = ((uint256(_amountToRedeem) * _redemptionQueueItem.cancelRedemptionFee) / FEE_PRECISION)
            .toUint120();

        // Calculations: increment unclaimedFees
        _redemptionQueueAccounting.unclaimedFees += uint128(_cancelRedemptionFee);

        // Calculations: Amount of veMetis back to the recipient, minus the fees
        _veMetisOut = _amountToRedeem - _cancelRedemptionFee;

        // If there is a LP lock, transfer the LP token back to the recipient
        uint256 _lpTokenAmount = _redemptionQueueItem.lpLockAmount;
        if (_lpTokenAmount > 0) {
            _redemptionQueueItem.lpClaimed = true;
            IERC20(_redemptionQueueItem.lpLockToken).safeTransfer(_recipient, _lpTokenAmount);
        }

        // Effects: burn the nft
        _burn(_nftId);

        // Effects: Write back accounting to state
        redemptionQueueAccounting = _redemptionQueueAccounting;

        // Effects: Mark nft as redeemed
        nftInformation[_nftId].hasBeenRedeemed = true;

        emit CancelRedemptionTicketNft({
            sender: msg.sender,
            recipient: _recipient,
            nftId: _nftId,
            veMetisOut: _veMetisOut,
            cancelRedemptionFee: _cancelRedemptionFee
        });

        // Interactions: transfer veMetis
        veMetis.safeTransfer({ to: _recipient, value: _veMetisOut });
    }

    /// @notice When someone redeems their NFT for Metis
    /// @param nftId the if of the nft redeemed
    /// @param sender the msg.sender
    /// @param recipient the recipient of the ether
    /// @param amountOut the amount of ether sent to the recipient
    event RedeemRedemptionTicketNft(uint256 indexed nftId, address indexed sender, address indexed recipient,  uint120 amountOut);

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

        // Effects: Subtract the amount from total liabilities
        redemptionQueueAccounting.etherLiabilities -= _redemptionQueueItem.amount;

        // Skip burning if the LP token is still locked
        if (_redemptionQueueItem.lpLockAmount == 0 || _redemptionQueueItem.lpClaimed) {
            // Effects: burn the Nft
            _burn(_nftId);
        }

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

        // Interactions: Transfer Metis to recipient, minus the fee
        METIS.safeTransfer(_recipient, _redemptionQueueItem.amount);

        emit RedeemRedemptionTicketNft({
            nftId: _nftId,
            sender: msg.sender,
            recipient: _recipient,
            amountOut: _redemptionQueueItem.amount
        });
    }

    event ReduceRedemptionMaturity(
        uint256 indexed nftId,
        address lpLockToken,
        uint256 lpLockAmount,
        uint64 reduceTime,
        uint64 newMaturityTimestamp
    );

    function reduceRedemptionMaturity(uint256 _nftId, address lpToken, uint256 lpAmount) external nonReentrant {
        require(lpToken != address(0), "RedemptionQueue: zero address");
        require(lpAmount > 0, "RedemptionQueue: amount is zero");

        // Checks: ensure proper nft ownership
        if (!_isAuthorized({owner:ownerOf(_nftId), spender: msg.sender, tokenId: _nftId })) revert Erc721CallerNotOwnerOrApproved();

        RedemptionQueueItem storage _redemptionQueueItem = nftInformation[_nftId];
        uint256 maturity = _redemptionQueueItem.maturity;

        // Checks: already reduced maturity
        if (_redemptionQueueItem.lpLockAmount > 0) {
            revert AlreadyReducedMaturity();
        }

        uint256 leftTime = maturity < block.timestamp ? 0 : maturity - block.timestamp;
        uint64 reduceTime = getReduceTime(lpToken, lpAmount, _redemptionQueueItem.amount);
        
        // Checks: reduce time exceeds limit
        if (reduceTime + config.minQueueLengthSecs() > leftTime) {
            revert ReduceTimeExceedsLimit();
        }

        // Effects: reduce maturity time and update LP lock information
        _redemptionQueueItem.maturity -= reduceTime;
        _redemptionQueueItem.lpLockAmount = lpAmount;
        _redemptionQueueItem.lpLockToken = lpToken;
        _redemptionQueueItem.lpLockMaturity = uint64(block.timestamp + config.reduceMaturityStakeSecs());

        // Interactions: Transfer LP token to contract
        IERC20(lpToken).safeTransferFrom(msg.sender, address(this), lpAmount);

        emit ReduceRedemptionMaturity(_nftId, lpToken, lpAmount, reduceTime, _redemptionQueueItem.maturity);
    }

    event UnlockLpToken(uint256 indexed nftId, address lpToken, uint256 lpAmount);

    function unlockLpToken(uint256 _nftId) external {
        // Checks: ensure proper nft ownership
        if (!_isAuthorized({owner:ownerOf(_nftId), spender: msg.sender, tokenId: _nftId })) revert Erc721CallerNotOwnerOrApproved();

        // Get queue information
        RedemptionQueueItem memory _redemptionQueueItem = nftInformation[_nftId];

        // Checks: Make sure LP token is locked
        if (_redemptionQueueItem.lpLockAmount == 0 || _redemptionQueueItem.lpClaimed) {
            revert LpTokenNotLocked();
        }

        // Checks: Make sure maturity was reached
        if (_redemptionQueueItem.lpLockMaturity > block.timestamp) {
            revert NotMatureYet({ currentTime: block.timestamp, maturity: _redemptionQueueItem.lpLockMaturity });
        }

        nftInformation[_nftId].lpClaimed = true;
        IERC20(nftInformation[_nftId].lpLockToken).safeTransfer(msg.sender, _redemptionQueueItem.lpLockAmount);

        emit UnlockLpToken(_nftId, _redemptionQueueItem.lpLockToken, _redemptionQueueItem.lpLockAmount);

        // If there is no Metis to redeem, burn the NFT
        if (_redemptionQueueItem.hasBeenRedeemed) {
            _burn(_nftId);
        }
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

    /// @notice LP token is not locked
    error LpTokenNotLocked();

    /// @notice Reduce time exceeds limit
    error ReduceTimeExceedsLimit();

    /// @notice already redeemed
    error AlreadyRedeemed();
}