// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interface/ICrossDomainEnabled.sol";
import "../interface/ILockingPool.sol";
import "../interface/ICrossDomainMessenger.sol";
import "../interface/IL1ERC20Bridge.sol";


/// @title Dealer
/// @notice The Dealer contract is responsible for the allocation of Metis tokens from Layer 2 to the LockingPool for sequencers, through sequencer agents.
contract Dealer is OwnableUpgradeable {

    /// @notice Emits when a new sequencer agent is added
    /// @param index index of the agent
    /// @param agent address of the agent
    event SequencerAgentAdded(uint32 index, address agent);

    /// @notice Emits when additional Metis tokens are locked for a sequencer.
    event SequencerRelocked(uint256 sequencerId, uint256 amount );

    /// @notice Emits when Metis tokens are minted on Layer 2.
    /// @param amount The amount of Metis tokens that have been minted.
    event L2MetisMinted(uint256 amount);

    /// @notice Emits when the sequencer agent template is set.
    /// @param oldValue The address of the old sequencer agent template.
    /// @param newValue The address of the new sequencer agent template.
    event SequencerAgentTemplateSet(address indexed oldValue, address indexed newValue);

    /// @notice Emits when the L2 gas limit is set.
    /// @param oldValue The old L2 gas limit.        
    event L2GasSet(uint32 oldValue, uint32 newValue);

    /// @notice Emits when withdrawRewards is set.
    /// @param oldValue The old withdrawRewards.
    /// @param newValue The new withdrawRewards.
    event WithdrawRewardsSet(bool oldValue, bool newValue);

    /// @notice The template contract for sequencer agents.
    address public sequencerAgentTemplate;

    /// @notice The Metis token.
    IERC20 public metis;

    /// @notice The LockingPool contract address.
    ILockingPool public lockingPool;

    /// @notice The LockingInfo contract address.
    ILockingInfo public lockingInfo;

    /// @notice The L2 messenger contract.
    ICrossDomainMessenger public messenger;

    /// @notice The ID of the L2 chain.
    uint256 public l2ChainId;

    /// @notice The address of the L2 MetisMinter contract.
    address public l2Minter;

    /// @notice The address of the L2 RewardDispatcher contract.
    address public l2RewardDispatcher;

    /// @notice The list of sequencer agents.
    mapping(uint32 => address) public sequencerAgents;

    /// @notice The number of sequencer agents.
    uint32 public sequencerAgentCount;

    /// @notice The list of active sequencer agent IDs.
    uint32[] public activeSequencerIds;

    /// @notice The sum of rewards of all sequencers.
    uint256 public sumRewards;

    /// @notice L2 gas limit.
    uint32 public l2Gas;

    /// @notice withdraw rewards
    bool public withdrawRewards;

    uint256 public sequencerId;
    address public sequencerSigner;
    bool public active;
    address public redemptionQueue;
    /// @notice Withdaws Metis token and deposits Metis tokens into the redemption queue.
    /// @param recipient The recipient of the  Metis token on  L2 (redemptionQueue).
    /// @param amount The amount of Metis tokens that have been deposited.
    event StakingAmountWithdrawnToRedemptionQueue(address indexed recipient, uint256 amount);

    /// @notice Emits when the sequencer initial balance is locked.
    /// @param sequencerSigner The address of the sequencer signer.
    /// @param amount The amount of Metis tokens that have been locked.
    /// @param active The status of the sequencer.
    event SequencerInitialBalanceLocked(address indexed sequencerSigner, uint256 amount,bool active);

    /// @notice Emits when the sequencer is terminated.
    event SequencerTerminated(uint256 indexed sequencerId, bool active);


    /// @notice Emits when the rewards are withdrawn.
    /// @param sequencerId The ID of the sequencer.
    /// @param reward The amount of rewards that have been withdrawn.
    event RewardsWithdrawn(uint256 indexed sequencerId, uint256 reward);

    event UnlockClaimed(uint256 indexed sequencerId, bool active);


    /// @notice Initializes the contract.
    function initialize( 
        address _metis, 
        address _lockingPool, 
        address _l1Bridge, 
        uint256 _l2ChainId, 
        uint32 _l2Gas, 
        address _l2Minter, 
        address _l2RewardDispatcher
        ) public initializer {
        require( _metis != address(0) && _lockingPool != address(0) && _l1Bridge != address(0) && _l2Minter != address(0) && _l2RewardDispatcher != address(0), "Dealer: zero address");
        __Ownable_init(msg.sender);
        metis = IERC20(_metis);
        lockingPool = ILockingPool(_lockingPool);
        lockingInfo = lockingPool.escrow();
        messenger = ICrossDomainMessenger(ICrossDomainEnabled(_l1Bridge).messenger());
        l2ChainId = _l2ChainId;
        l2Gas = _l2Gas;
        l2Minter = _l2Minter;
        l2RewardDispatcher = _l2RewardDispatcher;

    }

    /// @notice Locks Metis tokens for a new sequencer.
    /// @param _sequencerSigner The address of the sequencer signer.
    /// @param _amount The amount of Metis tokens to lock.
    /// @param _signerPubKey The public key of the sequencer signer.
    function lockFor(
        address _sequencerSigner,
        uint256 _amount,
        bytes memory _signerPubKey
    ) external onlyOwner {
        // Check if the Dealer contract has sufficient Metis balance
        uint256 dealerBalance = metis.balanceOf(address(this));
        require(dealerBalance >= _amount, "Dealer: Insufficient Metis balance");

        sequencerSigner = _sequencerSigner;

        // Approve the LockingInfo contract to spend the specified amount of tokens
        require(
            metis.approve(address(lockingInfo), type(uint256).max),
            "Dealer: Approval to LockingInfo failed"
        );

        // Attempt to lock the tokens by calling LockingPool's lockFor function
        lockingPool.lockWithRewardRecipient(sequencerSigner,l2Minter, _amount, _signerPubKey);

        // Retrieve and store the sequencer ID for tracking purposes
        sequencerId = lockingPool.seqSigners(sequencerSigner);
        active = true;
        emit SequencerInitialBalanceLocked(sequencerSigner, _amount, active);
    }

    /// @notice Facilitates the process of augmenting the locked Metis tokens and rewards for the currently active sequencer.
    /// @dev The `relock` function will call the `relock` function on the lockingPool contract.  
    function relock() external payable {
        require(active, "Dealer: no active sequencer");
        uint256 dealerBalance = metis.balanceOf(address(this));

        require(canStake(dealerBalance), "Dealer: exceed max lock");
        require (dealerBalance > 0, "Dealer: insufficient balance");
        // Approve the LockingInfo contract to spend the specified amount of tokens
        require(
            metis.approve(address(lockingInfo), type(uint256).max),
            "Dealer: Approval to LockingInfo failed"
        );

        lockingPool.relock(sequencerId, dealerBalance, false);
        emit SequencerRelocked(sequencerId, dealerBalance);
    }

    /// @dev Withraws rewards if available
   function claimRewards() external payable onlyOwner {
        uint256 _rewards = _getRewards();
        require (_rewards > 0,"Dealer:  Insufficient rewards");

        lockingPool.withdrawRewards{value: msg.value}(sequencerId, l2Gas);
        emit RewardsWithdrawn(sequencerId, _rewards);
    }

    /// @notice Unlock Metis tokens and terminate the sequencer.
    function unlock() external payable onlyOwner {
        lockingPool.unlock{value: msg.value}(sequencerId, l2Gas);
        active = false;
        emit SequencerTerminated(sequencerId, false);
    }

    /// @notice The `unlockClaim` function allows a sequencer to claim their Metis tokens after the unlocking waiting period has elapsed.
    function unlockClaim() external payable onlyOwner {
        lockingPool.unlockClaim{value: msg.value}(sequencerId, l2Gas);
        emit UnlockClaimed(sequencerId, false);
    }
    
    /// @notice partial withdrawl of locked Metis tokens and deposits them into the redemptionQueue.
    /// @param amount The amount of Metis tokens to withdraw.
    function withdrawStakingAmount(uint256 amount) public payable onlyOwner {
        require(amount > 0, "Dealer: invalid amount");
        require(_getLocked() >= lockingInfo.minLock() + amount, "Dealer: exceed min lock");

        lockingPool.withdraw(sequencerId, amount);
        
        address bridge = ILockingInfo(lockingInfo).bridge();
        IERC20(ILockingInfo(lockingInfo).l1Token()).approve(bridge, amount);
        IL1ERC20Bridge(bridge).depositERC20ToByChainId{value: msg.value}(l2ChainId, ILockingInfo(lockingInfo).l1Token(), ILockingInfo(lockingInfo).l2Token(), redemptionQueue, amount, l2Gas, "");
        emit StakingAmountWithdrawnToRedemptionQueue(redemptionQueue,amount);
    }

    function sequencerData() public view returns (ILockingPool.SequencerData memory) {
        return lockingPool.sequencers(sequencerId);
    }

    function canStake(uint256 _amount) public view returns (bool) {
        if (sequencerId == 0) {
            return false;
        }
        return _amount + _getLocked() <= lockingInfo.maxLock();
    }

    function stakingAmount() public view returns (uint256) {
        if (sequencerId == 0) {
            return 0;
        }
        return _getLocked();
    }

    function getRewards() external view returns (uint256) {
        return _getRewards();
    }

    function _getLocked() internal view returns (uint256 _locked) {
        ILockingPool.SequencerData memory seq = sequencerData();
        _locked =  seq.amount;
    }

    function _getRewards() internal view returns (uint256 _rewards) {
        ILockingPool.SequencerData memory seq = sequencerData();
        _rewards = seq.reward;

    }

    /// @notice Sets the L2 gas limit.
    /// @param _l2Gas The new L2 gas limit.
    /// @dev The L2 gas limit is used when minting eMetis tokens on Layer 2.
    function setL2Gas(uint32 _l2Gas) external onlyOwner {
        uint32 _old = l2Gas;
        l2Gas = _l2Gas;
        emit L2GasSet(_old, _l2Gas);
    }

    /// @notice Returns the total amount of Metis tokens that have been locked for all sequencers.
    function totalLocked() external view returns (uint256) {
        return sequencerData().amount;
    }



    // Setters
    function setL2Minter(address _l2MinterAddress) public onlyOwner{
        l2Minter = _l2MinterAddress;
    }

    function setRedemptionQueue(address _redemptionQueue) public onlyOwner {
        redemptionQueue = _redemptionQueue;
    }

    function setL2RewardDispatcher(address _l2RewardDispatcher) public onlyOwner {
        l2RewardDispatcher = _l2RewardDispatcher;
    }

    function setActive(bool _active) public onlyOwner {
        active = _active;
    }
}
