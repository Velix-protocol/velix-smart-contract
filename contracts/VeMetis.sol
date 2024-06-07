//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./interface/IVeMetis.sol";
import "./interface/IConfig.sol";
import "./Base.sol";

/**
 * @title VeMetis
 * @dev ERC20 token representing staked Metis (veMETIS) in the Velix protocol.
 */
contract VeMetis is IVeMetis, ERC20Upgradeable, Base {
    /**
     * @dev Initializes the contract with the configuration address and sets token details.
     * @param _config Address of the configuration contract.
     */
    function initialize(address _config) public initializer {
        __Base_init(_config);
        __ERC20_init("Velix Metis", "veMETIS");
    }

    /**
     * @notice Mint veMETIS tokens to a specified account.
     * @param account Address to receive the minted tokens.
     * @param amount Amount of tokens to mint.
     */
    function mint(address account, uint256 amount) external override {
        require(_msgSender() == config.veMetisMinter(), "VeMETIS: caller is not veMetisMinter");
        _mint(account, amount);
    }
}
