//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./interface/IConfig.sol";
import "./Base.sol";

/**
 * @title Config
 * @dev Manages configuration settings and roles for the protocol.
*/
contract Config is Initializable, IConfig, Base {
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

    uint256 public constant ADDRESS_VELIXVAULT =
        uint256(keccak256("ADDRESS_VELIXVAULT"));
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
    mapping(bytes32 => RoleData) public _roles;
    
    /**
     * @dev Initializes the contract by setting the default admin role to the deployer.
    */
    function initialize() external initializer {
        __Base_init(address(this));
        _grantRole(ADMIN_ROLE, msg.sender);
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
    ) public onlyRole(ADMIN_ROLE) {
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
    ) public onlyRole(ADMIN_ROLE) {
        configMap[ADDRESS_L1_DEALER] = uint256(uint160(_l1Dealer));
    }


    /**
     * @dev Sets the velixVault address.
     * @param _velixVault Address of the VelixVault contract.
     */
    function setVelixVault(
        address _velixVault
    ) public onlyRole(ADMIN_ROLE) {
        configMap[ADDRESS_VELIXVAULT] = uint256(uint160(_velixVault));
    }

    /**
     * @dev Sets the reward dispatcher address.
     * @param _rewardDispatcher Address of the reward dispatcher contract.
     */
    function setRewardDispatcher(
        address _rewardDispatcher
    ) public onlyRole(ADMIN_ROLE) {
        configMap[ADDRESS_REWARD_DISPATCHER] = uint256(
            uint160(_rewardDispatcher)
        );
    }
    // =========== updates  =========
    function setRedemptionQueue(address _redemptionQueueAddress) public onlyRole(ADMIN_ROLE){
        configMap[ADDRESS_REDEMPTION_QUEUE] = uint256(
            uint160(_redemptionQueueAddress)
        );
    }

    /// @notice get redemptionQueue address
    function redemptionQueue() external view override returns (address) {
        return address(uint160(configMap[ADDRESS_REDEMPTION_QUEUE]));
    }


    /// @notice get queue length in seconds 
    function queueLengthSecs() external view override returns (uint64) {
        return uint64(configMap[UINT64_QUEUE_LENGTH_SECS]);
    }


    /**
     * @dev Returns the velixVault address.
     */
    function velixVault() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_VELIXVAULT]));
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
    ) external override onlyRole(ADMIN_ROLE) {
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
    ) public override onlyRole(ADMIN_ROLE){
        require(
            _protocolTreasuryRatio <= 100000,
            "Config: protocolTreasuryRatio must be less than 10000"
        );
        configMap[UINT32_PROTOCOL_TREASURY_RATIO] = _protocolTreasuryRatio;
    }


    /// @notice set queue length in seconds
    /// @param _queueLengthSecs queue length in seconds
    function setQueueLengthSecs(uint64 _queueLengthSecs) public override onlyRole(ADMIN_ROLE) {
        uint64 oldValue = uint64(configMap[UINT64_QUEUE_LENGTH_SECS]);
        configMap[UINT64_QUEUE_LENGTH_SECS] = _queueLengthSecs;
        emit QueueLengthSecsSet(oldValue, _queueLengthSecs);
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
    ) public override onlyRole(ADMIN_ROLE) {
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
    function setRoleAdmin(bytes32 role, bytes32 adminRole) public override onlyRole(ADMIN_ROLE) {
        _setRoleAdmin(role, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     */
    function grantRole(
        bytes32 role,
        address account
    ) public override onlyRole(ADMIN_ROLE) {
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
