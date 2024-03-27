// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
// import "./interface/IConfig.sol";


// /// @title Base
// /// @notice The Base contract serves as a foundation for other contracts, providing key functionalities such as upgradeability, pausability, role-based access control, reentrancy protection, and the ability to recover ERC20 tokens.
// abstract contract Base is ContextUpgradeable, ReentrancyGuardUpgradeable {
//     using SafeERC20 for IERC20;

//     /// @notice The precision of the fee
//     uint64 public constant FEE_PRECISION = 1e6;

//     /// @notice The role for the timelock
//     bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

//     /// @notice The role for the operator
//     bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

//     /// @notice The role for the beta user
//     bytes32 public constant BETA_USER_ROLE = keccak256("BETA_USER_ROLE");

//     /// @notice sveMetis vault initial deposit amount
//     uint256 public constant INITIAL_DEPOSIT_AMOUNT = 1 ether;

//     /// @notice holds the address of the config contract
//     IConfig public config;

//     /// @notice the contract holds the tokens
//     mapping(address => bool) private holdTokens;

//     address private internalCalling;

//     modifier forUser() {
//         if (!config.isPublic() && internalCalling == address(0)) {
//             _checkRole(BETA_USER_ROLE);
//         }

//         require(!paused(), "forUser: paused");

//         _;
//     }

//     modifier internalOnly(address internalAddress) {
//         require(_msgSender() == internalAddress, "internal only");
//         internalCalling = internalAddress;
//         _;
//         internalCalling = address(0);
//     }

//     modifier onlyOperatorOrTimeLock() {
//         require(
//             config.hasRole(OPERATOR_ROLE, _msgSender()) ||
//                 config.hasRole(TIMELOCK_ROLE, _msgSender()),
//             "onlyOperatorOrTimeLock: caller does not have the operator or timelock role"
//         );
//         _;
//     }

//     modifier whenNotPaused() {
//         require(!paused(), "whenNotPaused: paused");
//         _;
//     }

//     /// @notice When the timelock or operator recovers ERC20 tokens mistakenly sent here
//     /// @param recipient Address of the recipient
//     /// @param token Address of the erc20 token
//     /// @param amount Amount of the erc20 token recovered
//     event RecoverErc20(address recipient, address token, uint256 amount);

//     /// @notice Recovers ERC20 tokens mistakenly sent to this contract
//     /// @param _tokenAddress Address of the tokenTIMELOCK_ROLE
//     /// @param _tokenAmount Amount of the token
//     function recoverErc20(address _tokenAddress, uint256 _tokenAmount) external onlyOperatorOrTimeLock {
//         require(!holdTokens[_tokenAddress], "recoverErc20: cannot recover hold token");
//         IERC20(_tokenAddress).safeTransfer({ to: msg.sender, value: _tokenAmount });
//         emit RecoverErc20({ recipient: msg.sender, token: _tokenAddress, amount: _tokenAmount });
//     }

//     /**
//      * Reject Metis transfer
//      */
//     receive() external payable {
//         revert("Base: not support Metis transfer");
//     }

//     /// @notice Retrieves the current paused status of the protocol.
//     /// @return A boolean value indicating whether the protocol is currently paused.
//     /// @dev This function is utilized within the 'whenNotPaused' modifier to halt certain functions when the protocol is paused.
//     function paused() public view returns (bool) {
//         return config.isPaused();
//     }

//     /// @notice Initializes the contract with the config contract address
//     /// @param _config The address of the config contract
//     function __Base_init(address _config, address[] memory _holdTokens) internal onlyInitializing {
//         __ReentrancyGuard_init();
//         config = IConfig(_config);

//         for (uint256 i = 0; i < _holdTokens.length; i++) {
//             holdTokens[_holdTokens[i]] = true;
//         }
//     }

//     /// @dev Revert with a standard message if `_msgSender()` is missing `role`.
//     function _checkRole(bytes32 role) internal view virtual {
//         _checkRole(role, _msgSender());
//     }

//     /// @dev Revert with a standard message if `account` is missing `role`.
//     /// The format of the revert reason is given by the following regular expression:
//     ///  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
//     function _checkRole(bytes32 role, address account) internal view virtual {
//         if (!config.hasRole(role, account)) {
//             revert(
//                 string(
//                     abi.encodePacked(
//                         "AccessControl: account ",
//                         Strings.toHexString(account),
//                         " is missing role ",
//                         Strings.toHexString(uint256(role), 32)
//                     )
//                 )
//             );
//         }
//     }
//     /**
//      * @dev This empty reserved space is put in place to allow future versions to add new
//      * variables without shifting down storage in the inheritance chain.
//      * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
//      */
//     uint256[30] private __gap;
// }

