// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Faucet {
    address public admin;
    mapping(address => uint256) public lastClaimedTime;

    uint256 constant claimInterval = 1 days;
    uint256 constant claimAmount = 0.5 ether;

    event EtherClaimed(address indexed recipient, uint256 amount);
    event LiquidityAdded(uint256 amount);
    event LiquidityRemoved(uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function claim() external {
        require(block.timestamp >= lastClaimedTime[msg.sender] + claimInterval, "You can only claim once every 24 hours");
        lastClaimedTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(claimAmount);
        emit EtherClaimed(msg.sender, claimAmount);
    }

    function addLiquidity() external payable onlyAdmin {
        require(msg.value > 0, "You can not add 0");
        emit LiquidityAdded(msg.value);
    }

    function removeLiquidity(uint256 amount) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient liquidity");
        payable(admin).transfer(amount);
        emit LiquidityRemoved(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}