//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "./interface/IL2ERC20Bridge.sol";
import "./Base.sol";
import "./interface/IRedemptionQueue.sol";

/** 
* @title VelixVault
* @notice The VelixVault contract is an implementation of the ERC4626 vault.
* It allows users to deposit Metis tokens in exchange for veMetis tokens,
* and vice versa. Additionally, it distributes locking rewards to veMetis token holders.
*/
contract VelixVault is Initializable, ERC4626Upgradeable, Base {

    using SafeERC20 for IERC20;



    event AssetsAdded(address indexed caller, uint256 assets);
    event DepositToL1Dealer(uint256 amount);
    event Minted(address indexed account, uint256 amount);
    
    function initialize( address _config) public initializer {
        __Base_init(_config);
        __ERC20_init(" veMetis", "veMetis");
        __ERC4626_init(IERC20(config.metis()));
    }


    /// @notice Sends Metis tokens from this contract to the RewardDispatcher address when received from L1Dealer contract.
    /// @param _amount The amount of Metis tokens to transfer
    function sendMetisRewards(uint256 _amount) external payable nonReentrant onlyBackend{
        require(_amount > 0, "MetisTransfer: Invalid amount");
        require(
            IERC20(config.metis()).balanceOf(address(this)) >= _amount,
            "MetisTransfer: Insufficient balance"
        );
        // Transfer the tokens to the reward dispatcher
        IERC20(config.metis()).safeTransferFrom( address(this),config.rewardDispatcher(), _amount);

    }

    /**
     * @notice Transfer Metis to L1 Dealer through the bridge
     * @param amount Amount of Metis to transfer
     */
    function depositToL1Dealer(uint256 amount) external payable onlyBackend {
        if (IERC20(config.metis()).allowance(address(this), config.bridge()) < amount) {
            IERC20(config.metis()).approve(config.bridge(), type(uint256).max);
        }
        
        // there are 7 days delay through the bridge
        IL2ERC20Bridge(config.bridge()).withdrawTo{value: msg.value}(config.metis(), config.l1Dealer(), amount, 0, "");
        emit DepositToL1Dealer(amount);
    }

    function addAssets(uint256 assets) internalOnly(config.rewardDispatcher()) external {
        IERC20 asset = IERC20(asset());
        asset.safeTransferFrom(_msgSender(), address(this), assets);
        _totalAssets += assets;
        emit AssetsAdded(_msgSender(), assets);
    }

    /// @notice returns the total assets in the vault
    function totalAssets() public view virtual override returns (uint256) {
        return _totalAssets;
    }
    
    /// @notice withdraw veMETIS from sveMETIS vault, user's sveMETIS will be burned
    /// @param caller caller of the function
    /// @param receiver receiver of veMETIS
    /// @param owner owner of METIS
    /// @param assets METIS amount
    /// @param shares veMETIS amount
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        _totalAssets -= assets;
        _burn(owner, shares);

        // Call enterRedemptionQueue from the RedemptionQueue smart contact which takes (3-5days)
        IRedemptionQueue(config.redemptionQueue()).enterRedemptionQueue(msg.sender, shares);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /// @notice deposit Metis to veMetis vault, user will get veMetis
    /// @param caller caller of the function
    /// @param receiver receiver of sveMetis
    /// @param assets amount of Metis
    /// @param shares amount of veMetis
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override  {
        super._deposit(caller, receiver, assets, shares);
        _totalAssets += assets;
        emit AssetsAdded(caller, assets);
    }

    function burn(
        address _from,
        uint256 _amount
    )  external {
        require(_msgSender() == config.redemptionQueue(), "VelixVault: caller is not redemptionQueue");
        _burn(_from, _amount);
    }
}
