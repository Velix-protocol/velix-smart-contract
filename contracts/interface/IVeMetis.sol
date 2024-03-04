//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IVeMetis is IERC20 {
    function mint(address user, uint256 amount) external;
}
