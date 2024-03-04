//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./interface/IVeMetis.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IL2ERC20Bridge.sol";
import "./interface/ICrossDomainEnabled.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./Base.sol";

contract VeMetisMinter is IVeMetisMinter, Base {
    using SafeERC20 for IERC20;

    address public rewardDispatcher;
    address public veMetis;
    address public sveMetis;
    address public metis;
    address public bridge;
    address public crossDomainMessenger;

    event Staked(uint256 amount);

    function initialize(address _config) public initializer {
        __Base_init(_config);
        veMetis = config.veMetis();
        sveMetis = config.sveMetis();
        metis = config.metis();
        bridge = config.bridge();
        crossDomainMessenger = ICrossDomainEnabled(bridge).messenger();
    }

    function setRewardDispatcher() public onlyRole(DEFAULT_ADMIN_ROLE) {
        rewardDispatcher = config.rewardDispatcher();
    }

    /**
     * Mint veMetis to user
     * @param account mint user
     * @param amount asset amount
     */
    function mint(address account, uint256 amount) external override {
        IERC20(metis).safeTransferFrom(_msgSender(), address(this), amount);
        IVeMetis(veMetis).mint(account, amount);
    }

    function mintFromL1(uint256 amount) external {
        require(
            _msgSender() == crossDomainMessenger,
            "VeMetisMinter: caller is not the crossDomainMessenger"
        );
        require(
            ICrossDomainMessenger(crossDomainMessenger)
                .xDomainMessageSender() == config.l1Dealer(),
            "VeMetisMinter: caller is not the l1Dealer"
        );
        IVeMetis(veMetis).mint(rewardDispatcher, amount);
    }

    /**
     * Withdraw transfer Metis to bridge
     */
    function stake(uint256 amount) external payable override {
        if (IERC20(metis).allowance(address(this), bridge) < amount) {
            IERC20(metis).approve(bridge, type(uint256).max);
        }
        IL2ERC20Bridge(bridge).withdrawTo{value: msg.value}(
            metis,
            config.l1Dealer(),
            amount,
            0,
            ""
        );
        emit Staked(amount);
    }

    /**
     * reject ETH transfer
     */
    receive() external payable {
        revert("VeMetisMinter: not support ETH transfer");
    }
}
