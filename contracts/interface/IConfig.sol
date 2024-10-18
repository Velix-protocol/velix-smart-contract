//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IConfig {
    function initialize() external;

    function veMetis() external view returns (address);

    function veMetisMinter() external view returns (address);

    function sveMetis() external view returns (address);

    function rewardDispatcher() external view returns (address);

    function metis() external view returns (address);

    function bridge() external view returns (address);

    function l1Dealer() external view returns (address);

    function protocolTreasury() external view returns (address);

    function protocolTreasuryRatio() external view returns (uint32);

    function redemptionQueue() external view returns (address);
    
    function redemptionFee() external view returns (uint64);
    function queueLengthSecs() external view returns (uint64);
    function cancelRedemptionFee() external view returns (uint64);
    function minQueueLengthSecs() external view returns (uint64);
    function reduceMaturityStakeSecs() external view returns (uint64);

    function setProtocolTreasury(address _protocolTreasury) external;
    

    function setProtocolTreasuryRatio(uint32 _protocolTreasuryRatio) external;
// ----------------------------------------------------------------
    function setRedemptionFee(uint64 _redemptionFee) external;
    function setQueueLengthSecs(uint64 _queueLengthSecs) external;
    function setCancelRedemptionFee(uint64 _cancelRedemptionFee) external;
    function setMinQueueLengthSecs(uint64 _minQueueLengthSecs) external;
    function setReduceMaturityStakeSecs(uint64 _reduceMaturityStakeSecs) external;
// ----------------------------------------------------------------
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;
}
