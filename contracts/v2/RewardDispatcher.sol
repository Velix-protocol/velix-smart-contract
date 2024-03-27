// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
// import "./interface/IVeMetisMinter.sol";
// import "./interface/IConfig.sol";
// import "./interface/ICrossDomainMessenger.sol";
// import "./interface/IsveMetis.sol";
// import "./Base.sol";

// /// @title RewardDispatcher
// /// @notice RewardDispatcher is the contract that dispatches rewards
// contract RewardDispatcher is Initializable, Base {
//     using SafeERC20 for IERC20;

//     IERC20 public veMetis;
//     ISeMetis public sveMetis;

//     /// @notice Dispatched is emitted when dispatch rewards
//     /// @param amount amount of veMetis dispatched
//     /// @param toTreasuryAmount amount of veMetis dispatched to protocol treasury
//     /// @param toVaultAmount amount of veMetis dispatched to sveMetis vault
//     event Dispatched(uint256 amount, uint256 toTreasuryAmount, uint256 toVaultAmount);

//     /// @notice initialize the contract
//     /// @param _config config contract address
//     function initialize(address _config) public initializer {
//         address[] memory _holdTokens = new address[](1);
//         _holdTokens[0] = IConfig(_config).veMetis();
//         __Base_init(_config, _holdTokens);
//         veMetis = IERC20(config.veMetis());
//         veMetis = ISeMetis(config.sveMetis());
//     }

//     /// @notice Dispatch rewards
//     /// @dev dispatch holding eMetis to protocol treasury and sveMetis vault, the ratio is configured in config contract
//     function dispatch() external whenNotPaused nonReentrant {
//         uint amount = veMetis.balanceOf(address(this));
//         require(amount > 0, "RewardDispatcher: no reward");

//         uint256 toTreasuryAmount = amount * config.protocolTreasuryRatio() / FEE_PRECISION;
//         uint256 toVaultAmount = amount - toTreasuryAmount;

//         veMetis.safeTransfer(config.protocolTreasury(), toTreasuryAmount);
//         veMetis.approve(address(sveMetis), toVaultAmount);
//         IsveMetis(sveMetis).addAssets(toVaultAmount);

//         emit Dispatched(amount, toTreasuryAmount, toVaultAmount);
//     }
// }
