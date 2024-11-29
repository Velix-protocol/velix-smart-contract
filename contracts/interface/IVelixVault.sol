//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IVelixVault is IERC20 {
    function depositFromVeMetisMinter(uint256 amount, address account) external;
    function addAssets(uint256 assets) external;
    function sendMetisRewards(uint256 _amount) external payable;
    function depositToL1Dealer(uint256 amount) external payable;
    function burn(address user, uint256 amount) external;
}