//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IVeMetis.sol";
import "./Base.sol";

/** 
* @title SveMetis
* @notice The SveMetis contract is an implementation of the ERC4626 vault.
* It allows users to deposit veMetis tokens in exchange for sveMetis tokens,
* and vice versa. Additionally, it distributes locking rewards to sveMetis token holders.
*/
contract SveMetis is ERC4626Upgradeable, Base {

    using SafeERC20 for IERC20;

    uint256 public _totalAssets;
    address public deployer;

    event AssetsAdded(address indexed caller, uint256 assets);
    function initialize( address _config) public initializer {
        __Base_init(_config);
        __ERC20_init(" Staked veMETIS", "sveMETIS");
        __ERC4626_init(IERC20(config.veMetis()));
        deployer = _msgSender();
    }


    function depositFromVeMetisMinter(uint256 assets, address receiver) internalOnly(config.veMetisMinter()) public returns (uint256) {
        return super.deposit(assets, receiver);
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
    /// @param owner owner of sveMETIS
    /// @param assets veMETIS amount
    /// @param shares sveMETIS amount
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

        _burn(owner, shares);
        _totalAssets -= assets;

        IERC20 asset = IERC20(asset());
        SafeERC20.safeTransfer(asset, receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /// @notice deposit veMETIS to sveMETIS vault, user will get sveMETIS
    /// @param caller caller of the function
    /// @param receiver receiver of sveMETIS
    /// @param assets amount of veMETIS
    /// @param shares amount of sveMETIS
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
}
