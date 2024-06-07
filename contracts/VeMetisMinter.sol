//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./interface/IVeMetis.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/ISveMetis.sol";
import "./interface/IL2ERC20Bridge.sol";
import "./interface/ICrossDomainEnabled.sol";
import "./interface/ICrossDomainMessenger.sol";
import "./Base.sol";

/**
 * @title VeMetisMinter
 * @dev Manages the minting and distribution of veMETIS tokens within the Velix protocol.
 */
contract VeMetisMinter is IVeMetisMinter, Base {
    using SafeERC20 for IERC20;

    address public veMetis;
    address public sveMetis;
    address public metis;
    address public bridge;
    address public crossDomainMessenger;

    event DepositToL1Dealer(uint256 amount);
    event Minted(address indexed account, uint256 amount);

    /**
     * @dev Initializes the contract with configuration addresses and sets initial deposit.
     * @param _config Address of the configuration contract.
     */
    function initialize(address _config) public initializer {
        __Base_init(_config);
        veMetis = config.veMetis();
        sveMetis = config.sveMetis();
        metis = config.metis();
        bridge = config.bridge();
        crossDomainMessenger = ICrossDomainEnabled(bridge).messenger();

        // Initial deposit to prevent inflation attacks
        _mintAndDeposit(_msgSender(), INITIAL_DEPOSIT_AMOUNT);
    }

    /**
     * @notice Mint veMetis to user
     * @param account Address to receive minted veMetis
     * @param amount Amount of veMetis to mint
     */
    function mint(address account, uint256 amount) public nonReentrant override {
        IERC20(metis).safeTransferFrom(_msgSender(), address(this), amount);
        IVeMetis(veMetis).mint(account, amount);
        emit Minted(_msgSender(), amount);
    }

    /**
     * @notice Mint veMetis from L1 as the reward
     * @param amount Amount of veMetis to mint
     */
    function mintFromL1(uint256 amount) external nonReentrant override {
        require(_msgSender() == crossDomainMessenger, "VeMetisMinter: caller is not the crossDomainMessenger");
        require(ICrossDomainMessenger(crossDomainMessenger).xDomainMessageSender() == config.l1Dealer(), "VeMetisMinter: caller is not the l1Dealer");
        IVeMetis(veMetis).mint(config.rewardDispatcher(), amount);
    }

    /**
     * @notice Transfer Metis to L1 Dealer through the bridge
     * @param amount Amount of Metis to transfer
     */
    function depositToL1Dealer(uint256 amount) external payable onlyBackend override {
        if (IERC20(metis).allowance(address(this), bridge) < amount) {
            IERC20(metis).approve(bridge, type(uint256).max);
        }

        IL2ERC20Bridge(bridge).withdrawTo{value: msg.value}(metis, config.l1Dealer(), amount, 0, "");
        emit DepositToL1Dealer(amount);
    }

    /**
     * @notice Mint veMETIS and deposit to sveMETIS vault, user will get sveMETIS 
     * @param account Address to receive sveMETIS
     * @param amount Amount of veMETIS to mint and deposit
     */
    function _mintAndDeposit(address account, uint256 amount) internal {
        require(amount > 0, "VeMetisMinter: amount is zero");
        mint(account, amount);
        IERC20(veMetis).approve(sveMetis, amount);
        ISveMetis(sveMetis).depositFromVeMetisMinter(amount, account);
    }
}
