//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IConfig.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./Base.sol";
import "./interface/ISveMetis.sol";

contract RewardDispatcher is Initializable, Base {
    using SafeERC20 for IERC20;

    address public metis;
    address public veMetisMinter;
    address public veMetis;
    address public sveMetis;
    address public bridge;
    address public crossDomainMessenger;

    event Dispatched(
        uint256 amount,
        uint256 protocolTreasuryAmount,
        uint256 sveMetisAmount
    );

    function initialize(address _config) public initializer {
        __Base_init(_config);
        veMetis = config.veMetis();
        sveMetis = config.sveMetis();
    }

    /**
     * @notice Dispatch rewards
     * @dev dispatch holding veMetis to protocol treasury and sveMetis vault
     */
    function dispatch() external onlyBackend {

        uint amount = IERC20(veMetis).balanceOf(address(this));
        require(amount > 0, "RewardDispatcher: no reward");

        uint256 toTreasuryAmount = amount * config.protocolTreasuryRatio() / 10000;
        uint256 toVaultAmount = amount - toTreasuryAmount;

        IERC20(veMetis).safeTransfer(config.protocolTreasury(), toTreasuryAmount);
        IERC20(veMetis).approve(address(sveMetis), toVaultAmount);
        ISveMetis(sveMetis).addAssets(toVaultAmount);

        emit Dispatched(amount, toTreasuryAmount, toVaultAmount);
    }
}
