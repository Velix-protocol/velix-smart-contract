//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "./interface/IVeMetisMinter.sol";
import "./interface/IVeMetis.sol";
import "./Base.sol";

contract SveMetis is ERC4626Upgradeable, Base {

    using SafeERC20 for IERC20;
    function initialize( address _config) public initializer {
        __Base_init(_config);
        __ERC20_init("sveMetis", "sveMetis");
        __ERC4626_init(IERC20(config.veMetis()));
    }

    function mintAndDeposit(uint256 assets, address receiver) external onlyRole(BETA_USER_ROLE) returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");
        uint256 shares = previewDeposit(assets);

        IVeMetisMinter veMetisMinter = IVeMetisMinter(config.veMetisMinter());
        IERC20 metis = IERC20(config.metis());

        metis.safeTransferFrom(_msgSender(), address(this), assets);
        metis.approve(address(veMetisMinter), assets);
        veMetisMinter.mint(address(this), assets);

        _mint(receiver, shares);

        return shares;
    }
    
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 withdrawAmount,
        uint256 shares
    ) internal override onlyRole(BETA_USER_ROLE) {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        _burn(owner, shares);

        IERC20 asset = IERC20(asset());
        SafeERC20.safeTransfer(asset, receiver, withdrawAmount);

        emit Withdraw(caller, receiver, owner, withdrawAmount, shares);
    }

    function _deposit(
        address caller,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override onlyRole(BETA_USER_ROLE) {
        super._deposit(caller, owner, assets, shares);
    }
}