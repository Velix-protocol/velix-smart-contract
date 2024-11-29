//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interface/IVelixVault.sol";
import "./interface/IConfig.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./interface/IVelixVault.sol";
import "./Base.sol";

/// @title RewardDispatcher
/// @notice RewardDispatcher is the contract that dispatches rewards
contract RewardDispatcher is Initializable, Base {
    using SafeERC20 for IERC20;
    uint256 public treasuryBalance;

    /// @notice Dispatched is emitted when dispatch rewards
    /// @param amount amount of Metis dispatched
    /// @param toTreasuryAmount amount of Metis dispatched to protocol treasury
    /// @param toVaultAmount amount of Metis dispatched to veMetis vault
    event Dispatched(uint256 amount, uint256 toTreasuryAmount, uint256 toVaultAmount);

    /// @notice initialize the contract
    /// @param _config config contract address
    function initialize(address _config) public initializer {
        __Base_init(_config);
    }

    /// @notice Dispatch rewards
    /// @dev dispatch holding metis to protocol treasury and veMetis vault
    function dispatch() external  nonReentrant onlyBackend {
        uint amount = IERC20(config.metis()).balanceOf(address(this));
        require(amount > 0, "RewardDispatcher: no reward available");

        uint256 toTreasuryAmount = amount * config.protocolTreasuryRatio() / FEE_PRECISION;
        uint256 toVaultAmount = amount - toTreasuryAmount;

        treasuryBalance += toTreasuryAmount;

        // Transfer the comission(protocol fee) to protocol the treasury 
        IERC20(config.metis()).safeTransfer(config.protocolTreasury(), amount);
        
        // Transfer rewards to the velixVault
        IERC20(config.metis()).approve(address(config.velixVault()), toVaultAmount);
        IVelixVault(config.velixVault()).addAssets(toVaultAmount);

        emit Dispatched(amount, toTreasuryAmount, toVaultAmount);
    }

}
