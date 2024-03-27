// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
// import "./interface/IConfig.sol";
// import "./Base.sol";

// /// @title Config
// /// @dev This contract manages the configuration for the protocol.
// contract Config is IConfig, Base {
//     /// @notice Emits when `role`'s admin role is set to `newAdminRole`
//     /// @param role role hash
//     /// @param previousAdminRole the old admin role
//     /// @param newAdminRole the new admin role
//     event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

//     /// @notice Emits when `account` is granted `role`.
//     /// @param role role hash
//     /// @param account role granted account
//     /// @param sender operator account
//     event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

//     /// @notice Emits when `account` is revoked `role`.
//     /// @param role role hash
//     /// @param account role revoked account
//     /// @param sender operator account
//     event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

//     /// @notice Emits when `isPublic` is set to `newValue`
//     /// @param oldValue old value of `isPublic`
//     /// @param newValue new value of `isPublic`
//     event PublicSet(bool oldValue, bool newValue);

//     /// @notice Emits when `protocolTreasury` is set to `newValue`
//     /// @param oldValue old value of `protocolTreasury`
//     /// @param newValue new value of `protocolTreasury`
//     event ProtocolTreasurySet(address oldValue, address newValue);

//     /// @notice Emits when `protocolTreasuryRatio` is set to `newValue`
//     /// @param oldValue old value of `protocolTreasuryRatio`
//     /// @param newValue new value of `protocolTreasuryRatio`
//     event ProtocolTreasuryRatioSet(uint64 oldValue, uint64 newValue);

//     /// @notice Emits when `vestingRatio` is set to `newValue`
//     /// @param oldValue old value of `vestingRatio`
//     /// @param newValue new value of `vestingRatio`
//     event VestingRatioSet(uint64 oldValue, uint64 newValue);

//     /// @notice Emits when `vestingDuration` is set to `newValue`
//     /// @param oldValue old value of `vestingDuration`
//     /// @param newValue new value of `vestingDuration`
//     event VestingDurationSet(uint64 oldValue, uint64 newValue);

//     /// @notice Emits when `queueLengthSecs` is set to `newValue`
//     /// @param oldValue old value of `queueLengthSecs`
//     /// @param newValue new value of `queueLengthSecs`
//     event QueueLengthSecsSet(uint64 oldValue, uint64 newValue);

//     /// @notice Emits when `earlyExitFee` is set to `newValue`
//     /// @param oldValue old value of `earlyExitFee`
//     /// @param newValue new value of `earlyExitFee`
//     event EarlyExitFeeSet(uint64 oldValue, uint64 newValue);

//     /// @notice Emits when `isPaused` is set to `newValue`
//     /// @param oldValue old value of `isPaused`
//     /// @param newValue new value of `isPaused`
//     event PausedSet(bool oldValue, bool newValue);

//     /// @notice Data structure for role
//     struct RoleData {
//         mapping(address => bool) members;
//         bytes32 adminRole;
//     }

//     bool isItPublic = true;  

//     /// @notice mapping role hash to role data
//     mapping(bytes32 => RoleData) public _roles;

//     // config keys
//     uint256 public constant BOOL_IS_PUBLIC = uint256(keccak256("BOOL_IS_PUBLIC"));
//     uint256 public constant BOOL_IS_PAUSED = uint256(keccak256("BOOL_IS_PAUSED"));
//     uint256 public constant ADDRESS_VEMETIS = uint256(keccak256("ADDRESS_VEMETIS"));
//     uint256 public constant ADDRESS_VEMETIS_MINTER = uint256(keccak256("ADDRESS_VEMETIS_MINTER"));
//     uint256 public constant ADDRESS_SVE_METIS = uint256(keccak256("ADDRESS_SVE_METIS"));
//     uint256 public constant ADDRESS_REWARD_DISPATCHER = uint256(keccak256("ADDRESS_REWARD_DISPATCHER"));
//     uint256 public constant ADDRESS_METIS = uint256(keccak256("ADDRESS_METIS"));
//     uint256 public constant ADDRESS_BRIDGE = uint256(keccak256("ADDRESS_BRIDGE"));
//     uint256 public constant ADDRESS_L1_DEALER = uint256(keccak256("ADDRESS_L1_DEALER"));
//     uint256 public constant ADDRESS_PROTOCOL_TREASURY = uint256(keccak256("ADDRESS_PROTOCOL_TREASURY"));
//     uint256 public constant UINT64_PROTOCOL_TREASURY_RATIO = uint256(keccak256("UINT64_PROTOCOL_TREASURY_RATIO"));

//     /// @notice mapping config key to config value
//     mapping(uint256 => uint256) public configMap;

//     /// @notice initialize config
//     function initialize() external initializer{
//         __Base_init(address(this), new address[](0));
//         _grantRole(TIMELOCK_ROLE, msg.sender);
//         setPublic(isItPublic);
//     }
    
//     // Setters
//     // ====================================================================================
//     function setIntialValues(
//         address _metis,
//         address _bridge,
//         address _protocolTreasury,
//         uint32 _protocolTreasuryRatio
//     ) public onlyOperatorOrTimeLock {
//         // set initialvaules
//         configMap[ADDRESS_METIS] = uint256(uint160(_metis));
//         configMap[ADDRESS_BRIDGE] = uint256(uint160(_bridge));
        
//         setProtocolTreasuryRatio(_protocolTreasuryRatio);
//         setProtocolTreasury(_protocolTreasury);
//     }

//     function setL1Dealer(
//         address _l1Dealer
//     ) public onlyOperatorOrTimeLock {
//         configMap[ADDRESS_L1_DEALER] = uint256(uint160(_l1Dealer));
//     }

//     function setVeMetis(address _veMetis) public onlyOperatorOrTimeLock {
//         configMap[ADDRESS_VEMETIS] = uint256(uint160(_veMetis));
//     }

//     function setVeMetisMinterAddress(
//         address _veMetisMinter
//     ) public onlyOperatorOrTimeLock {
//         configMap[ADDRESS_VEMETIS_MINTER] = uint256(uint160(_veMetisMinter));
//     }

//     function setSveMetis(
//         address _sveMetis
//     ) public onlyOperatorOrTimeLock {
//         configMap[ADDRESS_SVE_METIS] = uint256(uint160(_sveMetis));
//     }

//     function setRewardDispatcher(
//         address _rewardDispatcher
//     ) public onlyOperatorOrTimeLock {
//         configMap[ADDRESS_REWARD_DISPATCHER] = uint256(
//             uint160(_rewardDispatcher)
//         );
//     }
//     // ====================================================================================

//     /**
//      * @dev Revokes `role` from `account`.
//      *
//      * If `account` had been granted `role`, emits a {RoleRevoked} event.
//      *
//      * Requirements:
//      *
//      * - the caller must have ``role``'s admin role.
//      *
//      * May emit a {RoleRevoked} event.
//      */
//     function revokeRole(bytes32 role, address account) external override onlyOperatorOrTimeLock {
//         _revokeRole(role, account);
//     }

//     function setRoleAdmin(bytes32 role, bytes32 adminRole) external override onlyOperatorOrTimeLock {
//         _setRoleAdmin(role, adminRole);
//     }

//     function grantRole(bytes32 role, address account) external override onlyOperatorOrTimeLock {
//         _grantRole(role, account);
//     }

//     function setPaused(bool _isPaused) external override onlyOperatorOrTimeLock {
//         bool oldValue = configMap[BOOL_IS_PAUSED] == 1;
//         configMap[BOOL_IS_PAUSED] = _isPaused ? 1 : 0;
//         emit PausedSet(oldValue, _isPaused);
//     }

//     /// @notice whether the protocol is paused
//     function isPaused() external view override returns (bool) {
//         return configMap[BOOL_IS_PAUSED] == 1;
//     }

//     /// @notice get public (specifies whether the protocol is public or in beta mode)
//     function isPublic() external view override returns (bool) {
//         return configMap[BOOL_IS_PUBLIC] == 1;
//     }

//     function veMetis() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_VEMETIS]));
//     }

//     // Getters
//     function veMetisMinter() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_VEMETIS_MINTER]));
//     }

//     function sveMetis() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_SVE_METIS]));
//     }

//     function rewardDispatcher() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_REWARD_DISPATCHER]));
//     }

//     function metis() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_METIS]));
//     }

//     function bridge() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_BRIDGE]));
//     }

//     function l1Dealer() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_L1_DEALER]));
//     }

//     function protocolTreasury() public view override returns (address) {
//         return address(uint160(configMap[ADDRESS_PROTOCOL_TREASURY]));
//     }

//     function protocolTreasuryRatio() public view override returns (uint64) {
//         return uint32(configMap[UINT64_PROTOCOL_TREASURY_RATIO]);
//     }


//     /// @notice set public (specifies whether the protocol is public or in beta mode)
//     /// @param _isPublic is public
//     function setPublic(bool _isPublic) public onlyOperatorOrTimeLock {
//         bool oldValue = configMap[BOOL_IS_PUBLIC] == 1;
//         configMap[BOOL_IS_PUBLIC] = _isPublic ? 1 : 0;
//         emit PublicSet(oldValue, _isPublic);
//     }

//     /// @notice set protocol treasury address
//     /// @param _protocolTreasury protocol treasury address
//     function setProtocolTreasury(address _protocolTreasury) public override onlyOperatorOrTimeLock {
//         require(_protocolTreasury != address(0), "Config: protocolTreasury is zero address");
//         address oldValue = address(uint160(configMap[ADDRESS_PROTOCOL_TREASURY]));
//         configMap[ADDRESS_PROTOCOL_TREASURY] = uint256(uint160(_protocolTreasury));
//         emit ProtocolTreasurySet(oldValue, _protocolTreasury);
//     }

//     /// @notice set protocol treasury ratio
//     /// @param _protocolTreasuryRatio protocol treasury ratio
//     function setProtocolTreasuryRatio(uint64 _protocolTreasuryRatio) public override onlyOperatorOrTimeLock {
//         require(_protocolTreasuryRatio <= FEE_PRECISION, "Config: protocolTreasuryRatio must be less than 1000000");
//         uint64 oldValue = uint64(configMap[UINT64_PROTOCOL_TREASURY_RATIO]);
//         configMap[UINT64_PROTOCOL_TREASURY_RATIO] = _protocolTreasuryRatio;
//         emit ProtocolTreasuryRatioSet(oldValue, _protocolTreasuryRatio);
//     }


//     /// @notice check if account has role
//     /// @param role role hash
//     /// @param account account address
//     function hasRole(bytes32 role, address account) public view override returns (bool) {
//         return _roles[role].members[account];
//     }

//     /**
//      * @dev Returns the admin role that controls `role`. See {grantRole} and
//      * {revokeRole}.
//      *
//      * To change a role's admin, use {_setRoleAdmin}.
//      */
//     function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
//         return _roles[role].adminRole;
//     }

//     /**
//      * @dev Sets `adminRole` as ``role``'s admin role.
//      *
//      * Emits a {RoleAdminChanged} event.
//      */
//     function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
//         bytes32 previousAdminRole = getRoleAdmin(role);
//         _roles[role].adminRole = adminRole;
//         emit RoleAdminChanged(role, previousAdminRole, adminRole);
//     }

//     /**
//      * @dev Grants `role` to `account`.
//      *
//      * Internal function without access restriction.
//      *
//      * May emit a {RoleGranted} event.
//      */
//     function _grantRole(bytes32 role, address account) internal virtual {
//         if (!hasRole(role, account)) {
//             _roles[role].members[account] = true;
//             emit RoleGranted(role, account, _msgSender());
//         }
//     }

//     /**
//      * @dev Revokes `role` from `account`.
//      *
//      * Internal function without access restriction.
//      *
//      * May emit a {RoleRevoked} event.
//      */
//     function _revokeRole(bytes32 role, address account) internal virtual {
//         if (hasRole(role, account)) {
//             _roles[role].members[account] = false;
//             emit RoleRevoked(role, account, _msgSender());
//         }
//     }

// }