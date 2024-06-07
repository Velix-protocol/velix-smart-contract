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

contract VeMetisMinter is IVeMetisMinter, Base {
    using SafeERC20 for IERC20;

    address public rewardDispatcher;
    address public veMetis;
    address public sveMetis;
    address public metis;
    address public bridge;
    address public crossDomainMessenger;

    event DepositToL1Dealer(uint256 amount);
    event Minted(address indexed account, uint256 amount);

    function initialize(address _config) public initializer {
        __Base_init(_config);
        veMetis = config.veMetis();
        sveMetis = config.sveMetis();
        metis = config.metis();
        bridge = config.bridge();
        crossDomainMessenger = ICrossDomainEnabled(bridge).messenger();

        /**
         * @notice ERC-4626 vaults that are empty or nearly empty are susceptible to a frontrunning attack known as a donation or inflation attack.
         * @dev This attack occurs when an attacker "donates" to the vault, artificially inflating the price of a share and causing slippage that can lead to theft.
         * @dev To mitigate this issue, an initial significant deposit is made into the vault upon deployment, making price manipulation impractical.
         * @dev Specifically, an initial deposit is made into the seMetis vault to safeguard against this potential attack.
         */
        _mintAndDeposit(_msgSender(),INITIAL_DEPOSIT_AMOUNT);
    }

    function setRewardDispatcher() public onlyOperatorOrAdmin {
        rewardDispatcher = config.rewardDispatcher();
    }
  
    /**
     * Mint veMetis to user
     * @param account mint user
     * @param amount asset amount
     */
    function mint(address account, uint256 amount) external nonReentrant override {
        IERC20(metis).safeTransferFrom(_msgSender(), address(this), amount);
        IVeMetis(veMetis).mint(account, amount);
        emit Minted(_msgSender(), amount);
    }

    /**
     * @notice Mint eMetis from L1 as the reward
     * @param amount Metis amount
    */
    function mintFromL1(uint256 amount) external  nonReentrant override {
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
     * @notice Transfer Metis to L1 Dealer through the bridge
     * @param amount Metis amount
     */
    function depositToL1Dealer(uint256 amount) external payable  onlyBackend override {
        if (IERC20(metis).allowance(address(this), bridge) < amount) {
            IERC20(metis).approve(bridge, type(uint256).max);
        }

        // there are 7 days delay through the bridge
        IL2ERC20Bridge(bridge).withdrawTo{value: msg.value}(
            metis,
            config.l1Dealer(),
            amount,
            0,
            ""
        );
        emit DepositToL1Dealer(amount);
    }


    /// @notice Mint veMETIS and deposit to sveMETIS vault, user will get sveMETIS 
    /// @param account account to accept sveMETIS
    /// @param amount Metis amount
    function _mintAndDeposit(address account, uint256 amount) internal  {
        // user should ensure enough metis balance and allowance
        require(amount > 0, "VeMetisMinter: amount is zero");
        //Transfer  metis  tokens to VeMetisMinter
        IERC20(metis).safeTransferFrom(_msgSender(), address(this), amount);
        // Mints veMETIS and deposit to sveMETIS
        IVeMetis(veMetis).mint(account, amount);
        // Approve and deposit to veMETIS into sveMetis vault
        IERC20(veMetis).approve(sveMetis, amount);
        ISveMetis(sveMetis).depositFromVeMetisMinter(amount, account);
    }
}