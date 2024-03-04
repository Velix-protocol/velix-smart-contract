//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./interface/IConfig.sol";
import "./Base.sol";

contract Config is IConfig, Base {
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

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

    mapping(uint256 => uint256) public configMap;

    function initialize() external initializer {
        __Base_init(address(this));
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Setters
    function setIntialValues(
        address _metis,
        address _bridge,
        address _protocolTreasury,
        uint32 _protocolTreasuryRatio
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // set initialvaules
        configMap[ADDRESS_METIS] = uint256(uint160(_metis));
        configMap[ADDRESS_BRIDGE] = uint256(uint160(_bridge));
        configMap[ADDRESS_PROTOCOL_TREASURY] = uint256(
            uint160(_protocolTreasury)
        );
        setProtocolTreasuryRatio(_protocolTreasuryRatio);

        // grant initial roles
        _grantRole(INTERNAL_ROLE, _metis);
        _grantRole(INTERNAL_ROLE, _bridge);
        _grantRole(INTERNAL_ROLE, _protocolTreasury);
    }

    function setL1Dealer(
        address _l1Dealer
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        configMap[ADDRESS_L1_DEALER] = uint256(uint160(_l1Dealer));
        _grantRole(INTERNAL_ROLE, _l1Dealer);
    }

    function setVeMetis(address _veMetis) public onlyRole(DEFAULT_ADMIN_ROLE) {
        configMap[ADDRESS_VEMETIS] = uint256(uint160(_veMetis));
        _grantRole(INTERNAL_ROLE, _veMetis);
    }

    function setVeMetisMinterAddress(
        address _veMetisMinter
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        configMap[ADDRESS_VEMETIS_MINTER] = uint256(uint160(_veMetisMinter));
        _grantRole(INTERNAL_ROLE, _veMetisMinter);
    }

    function setSveMetis(
        address _sveMetis
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        configMap[ADDRESS_SVEMETIS] = uint256(uint160(_sveMetis));
        _grantRole(INTERNAL_ROLE, _sveMetis);
    }

    function setRewardDispatcher(
        address _rewardDispatcher
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        configMap[ADDRESS_REWARD_DISPATCHER] = uint256(
            uint160(_rewardDispatcher)
        );
        _grantRole(INTERNAL_ROLE, _rewardDispatcher);
    }

    // Getters
    function veMetis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_VEMETIS]));
    }

    function veMetisMinter() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_VEMETIS_MINTER]));
    }

    function sveMetis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_SVEMETIS]));
    }

    function rewardDispatcher() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_REWARD_DISPATCHER]));
    }

    function metis() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_METIS]));
    }

    function bridge() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_BRIDGE]));
    }

    function l1Dealer() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_L1_DEALER]));
    }

    function protocolTreasury() public view override returns (address) {
        return address(uint160(configMap[ADDRESS_PROTOCOL_TREASURY]));
    }

    function protocolTreasuryRatio() public view override returns (uint32) {
        return uint32(configMap[UINT32_PROTOCOL_TREASURY_RATIO]);
    }

    // setters  help
    function setProtocolTreasury(
        address _protocolTreasury
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _protocolTreasury != address(0),
            "Config: protocolTreasury is zero address"
        );
        configMap[ADDRESS_PROTOCOL_TREASURY] = uint256(
            uint160(_protocolTreasury)
        );
    }

    function setProtocolTreasuryRatio(
        uint32 _protocolTreasuryRatio
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _protocolTreasuryRatio <= 10000,
            "Config: protocolTreasuryRatio must be less than 10000"
        );
        configMap[UINT32_PROTOCOL_TREASURY_RATIO] = _protocolTreasuryRatio;
    }

    // Check role
    function hasRole(
        bytes32 role,
        address account
    ) public view override returns (bool) {
        return _roles[role].allowAll || _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(
        bytes32 role,
        address account
    ) public override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public override {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    function setRoleAdmin(
        bytes32 role,
        bytes32 adminRole
    ) public override onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        _setRoleAdmin(role, adminRole);
    }

    function grantRole(
        bytes32 role,
        address account
    ) public override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
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
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    function allowAll(
        bytes32 role,
        bool allow
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role].allowAll = allow;
    }
}
