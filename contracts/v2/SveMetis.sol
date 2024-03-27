// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
// import "./Base.sol";

// /// @title SveMETIS
// /// @notice The sveMetis contract is an implementation of the ERC4626 vault. It allows users to deposit veMETIS tokens in exchange for sveMETIS tokens, and vice versa. Additionally, it distributes locking rewards to sveMETIS token holders.
// contract SveMetis is ERC4626Upgradeable, Base {
//     using SafeERC20 for IERC20;

//     address public deployer;
//     address public rewardDispatcher;
//     address public veMetisMinter;
//     uint256 public _totalAssets;

//     function initialize(address _config) public initializer {
//         address[] memory _holdTokens = new address[](1);
//         _holdTokens[0] = IConfig(_config).veMetis();
//         __Base_init(_config, _holdTokens);
//         __ERC20_init("Staked Velix Metis", "sveMETIS");
//         __ERC4626_init(IERC20(config.veMetis()));
//         deployer = _msgSender();
        
//     }
//     // setters
//     function setVeMetisMinter() public onlyOperatorOrTimeLock {
//         veMetisMinter = config.veMetisMinter();
//     }

//      function setRewardDispatcher() public onlyOperatorOrTimeLock {
//         rewardDispatcher = config.rewardDispatcher();
//     }

//     function depositFromVeMetisMinter(
//         uint256 assets,
//         address receiver
//     ) public internalOnly(veMetisMinter) returns (uint256) {
//         return super.deposit(assets, receiver);
//     }

//     function addAssets(uint256 assets) external internalOnly(rewardDispatcher) {
//         IERC20 asset = IERC20(asset());
//         asset.safeTransferFrom(_msgSender(), address(this), assets);
//         _totalAssets += assets;
//     }

//     /// @notice returns the total assets in the vault
//     function totalAssets() public view virtual override returns (uint256) {
//         return _totalAssets;
//     }

//     /// @notice withdraw veMETIS from sveMETIS vault, user's sveMETIS will be burned
//     /// @param caller caller of the function
//     /// @param receiver receiver of veMETIS
//     /// @param owner owner of sveMETIS
//     /// @param assets veMETIS amount
//     /// @param shares veMETIS amount
//     function _withdraw(
//         address caller,
//         address receiver,
//         address owner,
//         uint256 assets,
//         uint256 shares
//     ) internal override forUser {
//         if (caller != owner) {
//             _spendAllowance(owner, caller, shares);
//         }

//         require(
//             owner != deployer ||
//                 assets + INITIAL_DEPOSIT_AMOUNT <= maxWithdraw(deployer),
//             "SveMetis: deployer should keep the initial deposit amount"
//         );

//         _burn(owner, shares);

//         IERC20 asset = IERC20(asset());
//         SafeERC20.safeTransfer(asset, receiver, assets);
//         _totalAssets -= assets;

//         emit Withdraw(caller, receiver, owner, assets, shares);
//     }

//     /// @notice deposit veMETIS to sveMETIS vault, user will get sveMETIS
//     /// @param caller caller of the function
//     /// @param receiver receiver of sveMETIS
//     /// @param assets amount of veMETIS
//     /// @param shares amount of sveMETIS
//     function _deposit(
//         address caller,
//         address receiver,
//         uint256 assets,
//         uint256 shares
//     ) internal override forUser {
//         super._deposit(caller, receiver, assets, shares);
//         _totalAssets += assets;
//     }

//     /// @dev the deployer should keep the initial deposit amount
//     function _beforeTokenTransfer(
//         address from,
//         uint256 amount
//     ) internal virtual {
//         require(
//             from == address(0) ||
//                 from != deployer ||
//                 previewWithdraw(amount) + INITIAL_DEPOSIT_AMOUNT <=
//                 maxWithdraw(deployer),
//             "SveMetis: deployer should keep the initial deposit amount"
//         );
//     }
// }
