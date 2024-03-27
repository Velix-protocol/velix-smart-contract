// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// interface IConfig {
//     function initialize() external;
//     function setPaused(bool _isPaused) external;
//     function setPublic(bool _isPublic) external;
//     function setProtocolTreasury(address _protocolTreasury) external;
//     function setProtocolTreasuryRatio(uint64 _protocolTreasuryRatio) external;
//     function hasRole(bytes32 role, address account) external view returns (bool);
//     function getRoleAdmin(bytes32 role) external view returns (bytes32);
//     function grantRole(bytes32 role, address account) external;
//     function revokeRole(bytes32 role, address account) external;
//     function setRoleAdmin(bytes32 role, bytes32 adminRole) external;
//     function isPaused() external view returns (bool);
//     function isPublic() external view returns (bool);
//     function veMetis() external view returns (address);
//     function veMetisMinter() external view returns (address);
//     function sveMetis() external view returns (address);
//     function rewardDispatcher() external view returns (address);
//     function metis() external view returns (address);
//     function bridge() external view returns (address);
//     function l1Dealer() external view returns (address);
//     function protocolTreasury() external view returns (address);
//     function protocolTreasuryRatio() external view returns (uint64);
// }