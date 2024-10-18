//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./interface/IConfig.sol";
import "./Base.sol";

/**
 * @title Config
 * @dev Manages configuration settings and roles for the protocol.
*/
contract Config is IConfig, Base {
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed senderFini
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /// @notice Emits when `redemptionFee` is set to `newValue`
    /// @param oldValue old value of `redemptionFee`
    /// @param newValue new value of `redemptionFee`
    event RedemptionFeeSet(uint64 oldValue, uint64 newValue);

    /// @notice Emits when `queueLengthSecs` is set to `newValue`
    /// @param oldValue old value of `queueLengthSecs`
    /// @param newValue new value of `queueLengthSecs`
    event QueueLengthSecsSet(uint64 oldValue, uint64 newValue);

    /// @notice Emits when `cancelRedemptionFee` is set to `newValue`
    /// @param oldValue old value of `cancelRedemptionFee`
    /// @param newValue new value of `cancelRedemptionFee`
    event CancelRedemptionFeeSet(uint64 oldValue, uint64 newValue);

    /// @notice Emits when `minQueueLengthSecs` is set to `newValue`
    /// @param oldValue old value of `minQueueLengthSecs`
    /// @param newValue new value of `minQueueLengthSecs`
    event MinQueueLengthSecs(uint64 oldValue, uint64 newValue);

    /// @notice Emits when `reduceMaturityStakeSecs` is set to `newValue`
    /// @param oldValue old value of `reduceMaturityStakeSecs`
    /// @param newValue new value of `reduceMaturityStakeSecs`
    event ReduceMaturityStakeSecsSet(uint64 oldValue, uint64 newValue);

    /// @notice Emits when `isPaused` is set to `newValue`
    /// @param oldValue old value of `isPaused`
    /// @param newValue new value of `isPaused`
    event PausedSet(bool oldValue, bool newValue);
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
        bool allowAll;
    }

    mapping(bytes32 => RoleData) public _roles;

    uint256 public constant ADDRESS_VEMETIS =
        uint256(keccak256("ADDRESS_VEMETIS"));
    uint256 public constant ADDRESS_VEMETIS_MINTER =
        uint256(keccak256("ADDRESS_VEMETIS_MINTER"));

    uint256 public constant ADDRESS_SVEMETIS =
        uint256(keccak256("ADDRESS_SVEMETIS"));
    uint256 public constant ADDRESS_REWARD_DISPATCHER =
        uint256(keccak256("ADDRESS_REWARD_DISPATCHER"));
    uint256 public constant ADDRESS_METIS = uint256(keccak256("ADDRESS_METIS"));
    uint256 public constant ADDRESS_BRIDGE =
        uint256(keccak256("ADDRESS_BRIDGE"));
    uint256 public constant ADDRESS_L1_DEALER =
        uint256(keccak256("ADDRESS_L1_DEALER"));
    uint256 public constant ADDRESS_PROTOCOL_TREASURY =
        uint256(keccak256("ADDRESS_PROTOCOL_TREASURY"));
    uint256 public constant UINT32_PROTOCOL_TREASURY_RATIO =
        uint256(keccak256("UINT32_PROTOCOL_TREASURY_RATIO"));
        // =======updates =====
    uint256 public constant ADDRESS_REDEMPTION_QUEUE = 
        uint256(keccak256("ADDRESS_REDEMPTION_QUEUE"));
    uint256 public constant UINT64_REDEMPTION_FEE = 
        uint256(keccak256("UINT64_REDEMPTION_FEE"));
    uint256 public constant UINT64_QUEUE_LENGTH_SECS =
         uint256(keccak256("UINT64_QUEUE_LENGTH_SECS"));
    uint256 public constant UINT64_CANCEL_REDEMPTION_FEE =
         uint256(keccak256("UINT64_CANCEL_REDEMPTION_FEE"));
    uint256 public constant UINT64_MIN_QUEUE_LENGTH_SECS = 
        uint256(keccak256("UINT64_MIN_QUEUE_LENGTH_SECS"));
    uint256 public constant UINT64_REDUCE_MATURITY_STAKE_SECS = 
        uint256(keccak256("UINT64_REDUCE_MATURITY_STAKE_SECS"));

    mapping(uint256 => uint256) public configMap;

    /**
     * @dev Initializes the contract by setting the default admin role to the deployer.
    */
    function initialize() external initializer {
        __Base_init(address(this));
        _grantRole(TIMELOCK_ROLE, msg.sender);
    }

    /**
     * @dev Sets initial values for the configuration.
     * @param _metis Address of the Metis token.
     * @param _bridge Address of the bridge contract.
     * @param _protocolTreasury Address of the protocol treasury.
     * @param _protocolTreasuryRatio Ratio for the protocol treasury.
    */
    function setIntialValues(
        address _metis,
        address _bridge,
        address _protocolTreasury,
        uint32 _protocolTreasuryRatio
    ) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_METIS] = uint256(uint160(_metis));
        configMap[ADDRESS_BRIDGE] = uint256(uint160(_bridge));
        configMap[ADDRESS_PROTOCOL_TREASURY] = uint256(
            uint160(_protocolTreasury)
        );
        setProtocolTreasuryRatio(_protocolTreasuryRatio);
    }

    /**
     * @dev Sets the L1 dealer address.
     * @param _l1Dealer Address of the L1 dealer.
     */
    function setL1Dealer(
        address _l1Dealer
    ) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_L1_DEALER] = uint256(uint160(_l1Dealer));
    }

    /**
     * @dev Sets the veMetis address.
     * @param _veMetis Address of the veMetis contract.
     */
    function setVeMetis(address _veMetis) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_VEMETIS] = uint256(uint160(_veMetis));
    }

    /**
     * @dev Sets the veMetis minter address.
     * @param _veMetisMinter Address of the veMetis minter contract.
     */
    function setVeMetisMinterAddress(
        address _veMetisMinter
    ) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_VEMETIS_MINTER] = uint256(uint160(_veMetisMinter));
    }

    /**
     * @dev Sets the sVeMetis address.
     * @param _sveMetis Address of the sVeMetis contract.
     */
    function setSveMetis(
        address _sveMetis
    ) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_SVEMETIS] = uint256(uint160(_sveMetis));
    }

    /**
     * @dev Sets the reward dispatcher address.
     * @param _rewardDispatcher Address of the reward dispatcher contract.
     */
    function setRewardDispatcher(
        address _rewardDispatcher
    ) public onlyTimeLockOrAdmin {
        configMap[ADDRESS_REWARD_DISPATCHER] = uint256(
            uint160(_rewardDispatcher)
        );
    }
    // =========== updates  =========
    function setRedemptionQueue(address _redemptionQueueAddress) public onlyTimeLockOrAdmin{
        configMap[ADDRESS_REDEMPTION_QUEUE] = uint256(
            uint160(_redemptionQueueAddress)
        );
    }

    /// @notice get redemptionQueue address
    function redemptionQueue() external view override returns (address) {
        return address(uint160(configMap[ADDRESS_REDEMPTION_QUEUE]));
    }

       /// @notice get redemption fee
    function redemptionFee() external view override returns (uint64) {
        return uint64(configMap[UINT64_REDEMPTION_FEE]);
    }

    /// @notice get queue length in seconds 
    function queueLengthSecs() external view override returns (uint64) {
        return uint64(configMap[UINT64_QUEUE_LENGTH_SECS]);
    }

    /// @notice get cancel redemption fee
    function cancelRedemptionFee() external view override returns (uint64) {
        return uint64(configMap[UINT64_CANCEL_REDEMPTION_FEE]);
    }

    /// @notice get min queue length in seconds
    function minQueueLengthSecs() external view override returns (uint64) {
        return uint64(configMap[UINT64_MIN_QUEUE_LENGTH_SECS]);
    }

    /// @notice get reduce maturity stake in seconds
    function reduceMaturityStakeSecs() external view override returns (uint64) {
        return uint64(configMap[UINT64_REDUCE_MATURITY_STAKE_SECS]);
    }
     // =========== updates  =========

    /**
     * @dev Returns the veMetis address.
     */
    function veMetis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_VEMETIS]));
    }

    /**
     * @dev Returns the veMetis minter address.
     */
    function veMetisMinter() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_VEMETIS_MINTER]));
    }

    /**
     * @dev Returns the sVE Metis address.
     */
    function sveMetis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_SVEMETIS]));
    }

    /**
     * @dev Returns the reward dispatcher address.
     */
    function rewardDispatcher() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_REWARD_DISPATCHER]));
    }

    /**
     * @dev Returns the Metis address.
     */
    function metis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_METIS]));
    }

    /**
     * @dev Returns the bridge address.
     */
    function bridge() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_BRIDGE]));
    }

    /**
     * @dev Returns the L1 dealer address.
     */
    function l1Dealer() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_L1_DEALER]));
    }

    /**
     * @dev Returns the protocol treasury address.
     */
    function protocolTreasury() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_PROTOCOL_TREASURY]));
    }

    /**
     * @dev Returns the protocol treasury ratio.
     */
    function protocolTreasuryRatio() public view override returns (uint32) {
        return uint32(configMap[UINT32_PROTOCOL_TREASURY_RATIO]);
    }

    /**
     * @dev Sets the protocol treasury address.
     * @param _protocolTreasury Address of the protocol treasury.
     */

    function setProtocolTreasury(
        address _protocolTreasury
    ) external override onlyTimeLockOrAdmin {
        require(
            _protocolTreasury != address(0),
            "Config: protocolTreasury is zero address"
        );
        configMap[ADDRESS_PROTOCOL_TREASURY] = uint256(
            uint160(_protocolTreasury)
        );
    }

    /**
     * @dev Sets the protocol treasury ratio.
     * @param _protocolTreasuryRatio Ratio for the protocol treasury.
     */
    function setProtocolTreasuryRatio(
        uint32 _protocolTreasuryRatio
    ) public override onlyTimeLockOrAdmin {
        require(
            _protocolTreasuryRatio <= 10000,
            "Config: protocolTreasuryRatio must be less than 10000"
        );
        configMap[UINT32_PROTOCOL_TREASURY_RATIO] = _protocolTreasuryRatio;
    }

        /// @notice set redemption fee
    /// @param _redemptionFee redemption fee in precision of 1000000
    function setRedemptionFee(uint64 _redemptionFee) public override onlyTimeLockOrAdmin {
        require(_redemptionFee <= FEE_PRECISION, "Config: redemptionFee must be less than 1000000");
        uint64 oldValue = uint64(configMap[UINT64_REDEMPTION_FEE]);
        configMap[UINT64_REDEMPTION_FEE] = _redemptionFee;
        emit RedemptionFeeSet(oldValue, _redemptionFee);
    }

    /// @notice set queue length in seconds
    /// @param _queueLengthSecs queue length in seconds
    function setQueueLengthSecs(uint64 _queueLengthSecs) public override onlyTimeLockOrAdmin {
        uint64 oldValue = uint64(configMap[UINT64_QUEUE_LENGTH_SECS]);
        configMap[UINT64_QUEUE_LENGTH_SECS] = _queueLengthSecs;
        emit QueueLengthSecsSet(oldValue, _queueLengthSecs);
    }

    /// @notice set cancel redemption fee
    /// @param _cancelRedemptionFee cancel redemption fee in precision of 1000000
    function setCancelRedemptionFee(uint64 _cancelRedemptionFee) public override onlyTimeLockOrAdmin {
        uint64 oldValue = uint64(configMap[UINT64_CANCEL_REDEMPTION_FEE]);
        configMap[UINT64_CANCEL_REDEMPTION_FEE] = _cancelRedemptionFee;
        emit CancelRedemptionFeeSet(oldValue, _cancelRedemptionFee);
    }

    /// @notice set min queue length in seconds
    /// @param _minQueueLengthSecs min queue length in seconds
    function setMinQueueLengthSecs(uint64 _minQueueLengthSecs) public override onlyTimeLockOrAdmin {
        uint64 oldValue = uint64(configMap[UINT64_MIN_QUEUE_LENGTH_SECS]);
        configMap[UINT64_MIN_QUEUE_LENGTH_SECS] = _minQueueLengthSecs;
        emit MinQueueLengthSecs(oldValue, _minQueueLengthSecs);
    }

    /// @notice set reduce maturity stake in seconds
    /// @param _reduceMaturityStakeSecs reduce maturity stake in seconds
    function setReduceMaturityStakeSecs(uint64 _reduceMaturityStakeSecs) public override onlyTimeLockOrAdmin {
        uint64 oldValue = uint64(configMap[UINT64_REDUCE_MATURITY_STAKE_SECS]);
        configMap[UINT64_REDUCE_MATURITY_STAKE_SECS] = _reduceMaturityStakeSecs;
        emit ReduceMaturityStakeSecsSet(oldValue, _reduceMaturityStakeSecs);
    }

    /**
     * @dev Checks if an account has a specific role.
     * @param role Role identifier.
     * @param account Address to check.
     * @return True if the account has the role, false otherwise.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view override returns (bool) {
        return _roles[role].allowAll || _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`.
     * @param role Role identifier.
     * @return Admin role identifier.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Revokes `role` from `account`.
     * @param role Role identifier.
     * @param account Address to revoke role from.
     */
    function revokeRole(
        bytes32 role,
        address account
    ) public override onlyTimeLockOrAdmin() {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     * @param role Role identifier.
     * @param account Address to renounce role for.
     */
    function renounceRole(bytes32 role, address account) public override {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );
        _revokeRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as `role`'s admin role.
     */
    function setRoleAdmin(bytes32 role, bytes32 adminRole) public override onlyTimeLockOrAdmin {
        _setRoleAdmin(role, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     */
    function grantRole(
        bytes32 role,
        address account
    ) public override onlyTimeLockOrAdmin {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
