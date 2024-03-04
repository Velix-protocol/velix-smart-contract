//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IConfig.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./Base.sol";

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
        metis = config.metis();
        veMetisMinter = config.veMetisMinter();
        veMetis = config.veMetis();
        sveMetis = config.sveMetis();

        IERC20(metis).approve(veMetisMinter, type(uint256).max);
    }

    /**
     * Convert holding Metis to veMETIS, and then dispatch to protocol treasury and sveMetis vault
     */
    function dispatch(uint metisAmount) external {
        if (metisAmount > 0) {
            IERC20(metis).transferFrom(msg.sender, address(this), metisAmount);
            IVeMetisMinter(veMetisMinter).mint(address(this), metisAmount);
        }

        uint amount = IERC20(veMetis).balanceOf(address(this));
        uint256 protocolTreasuryAmount = (amount *
            config.protocolTreasuryRatio()) / 10000;
        uint256 sveMetisAmount = amount - protocolTreasuryAmount;

        IERC20(veMetis).safeTransfer(
            config.protocolTreasury(),
            protocolTreasuryAmount
        );
        IERC20(veMetis).safeTransfer(sveMetis, sveMetisAmount);

        emit Dispatched(amount, protocolTreasuryAmount, sveMetisAmount);
    }
}
