//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IConfig.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./interface/ISveMetis.sol";
import "./Base.sol";

/// @title RewardDispatcher
/// @notice RewardDispatcher is the contract that dispatches rewards
contract RewardDispatcher is Initializable, Base {
    using SafeERC20 for IERC20;
    uint256 public treasuryBalance;

    /// @notice Dispatched is emitted when dispatch rewards
    /// @param amount amount of veMetis dispatched
    /// @param toTreasuryAmount amount of veMetis dispatched to protocol treasury
    /// @param toVaultAmount amount of veMetis dispatched to sveMetis vault
    event Dispatched(uint256 amount, uint256 toTreasuryAmount, uint256 toVaultAmount);

    /// @notice initialize the contract
    /// @param _config config contract address
    function initialize(address _config) public initializer {
        __Base_init(_config);
    }

    /// @notice Dispatch rewards
    /// @dev dispatch holding veMetis to protocol treasury and sveMetis vault, the ratio is configured in config contract
    // function dispatch() external whenNotPaused nonReentrant onlyBackend {
    function dispatch() external  nonReentrant onlyBackend {
        uint amount = IERC20(config.veMetis()).balanceOf(address(this));
        require(amount > 0, "RewardDispatcher: no reward");

        uint256 toTreasuryAmount = amount * config.protocolTreasuryRatio() / FEE_PRECISION;
        uint256 toVaultAmount = amount - toTreasuryAmount;

        treasuryBalance += toTreasuryAmount;
        IERC20(config.veMetis()).approve(address(config.sveMetis()), toVaultAmount);
        ISveMetis(config.sveMetis()).addAssets(toVaultAmount);

        emit Dispatched(amount, toTreasuryAmount, toVaultAmount);
    }

    function withdrawTreasury(uint256 amount, bool redeem) external onlyBackend {
        require(amount <= treasuryBalance, "RewardDispatcher: insufficient balance");
        treasuryBalance -= amount;

        if (redeem) {
            IVeMetisMinter(config.veMetisMinter()).redeemToTreasury(amount);
        } else {
            IERC20(config.veMetis()).safeTransfer(config.protocolTreasury(), amount);
        }
    }
}
