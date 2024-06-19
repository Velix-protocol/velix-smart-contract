//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./interface/IConfig.sol";

abstract contract Base is ContextUpgradeable, ReentrancyGuardUpgradeable {

    /// @notice The role for the tmelock
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    
    /// @notice The role for the admin
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice The role for the backend
    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");

    /// @notice sveMetis vault initial deposit amount
    uint256 public constant INITIAL_DEPOSIT_AMOUNT = 1 ether;

    /// @notice holds the address of the config contract
    IConfig public config;

    address private internalCalling;

    modifier onlyTimeLockOrAdmin() {
        require(
            config.hasRole(TIMELOCK_ROLE, _msgSender()) ||
            config.hasRole(ADMIN_ROLE, _msgSender()),
            "onlyTimeLockOrAdmin: caller does not have the timelock or admin role"
        );
        _;
    }

    modifier onlyBackend() {
        _checkRole(BACKEND_ROLE);
        _;
    }

    modifier internalOnly(address internalAddress) {
        require(_msgSender() == internalAddress, "internal only");
        internalCalling = internalAddress;
        _;
        internalCalling = address(0);
    }

    /// @notice Initializes the contract with the config contract address
    /// @param _config The address of the config contract
    function __Base_init(address _config) internal onlyInitializing {
        config = IConfig(_config);
        __ReentrancyGuard_init();
        __Context_init();
    }

  /// @dev Revert with a standard message if `_msgSender()` is missing `role`.
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!config.hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * reject Metis transfer
     */
    receive() external payable {
        revert("VeMetisMinter: not support Metis transfer");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[30] private __gap;
}
