//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVeMetisMinter {
    function mint(address user, uint256 amount) external;
    function sendMetisRewards(uint256 _amount) external payable;
    function depositToL1Dealer(uint256 amount) external payable;
    function redeemToTreasury(uint256 amount) external;
}
