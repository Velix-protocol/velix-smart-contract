//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./interface/IVeMetis.sol";
import "./interface/IConfig.sol";
import "./Base.sol";

contract VeMetis is IVeMetis, ERC20Upgradeable, Base {
    address public minter;

    function initialize(address _config) public initializer {
        __Base_init(_config);
        __ERC20_init("Velix Metis", "veMETIS");
    }

    function setMinter() public onlyOperatorOrAdmin {
        minter = config.veMetisMinter();
    }

    /**
     * Mint veMETIS to user
     * @param account mint user
     * @param amount asset amount
     */
    function mint(address account, uint256 amount) external override {
        require(_msgSender() == minter, "VeMETIS: caller is not the minter");
        _mint(account, amount);
    }
}
