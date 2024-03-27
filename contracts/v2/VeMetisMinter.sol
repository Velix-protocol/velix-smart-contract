// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import "./SveMetis.sol";
// import "./ERC20PermitPermissionedMint.sol";
// import "./interface/IVeMetisMinter.sol";
// import "./interface/IL2ERC20Bridge.sol";
// import "./interface/ICrossDomainEnabled.sol";
// import "./interface/ICrossDomainMessenger.sol";
// import "./interface/IsveMetis.sol";
// import "./Base.sol";

// /// @title veMetisMinter
// /// @notice veMetisMinter is the contract that mints veMETIS
// contract VeMetisMinter is IVeMetisMinter, Base {
//     using SafeERC20 for IERC20;

//     /// @notice rewardDispatcher is the contract that dispatches rewards
//     address public rewardDispatcher;

//     /// @notice veMetis is the veMetis contract address
//     address public veMetis;

//     /// @notice sveMetis is the sveMetis contract address
//     address public sveMetis;

//     /// @notice metis is the metis contract address
//     address public metis;

//     /// @notice bridge is the L2 bridge contract address
//     address public bridge;

//     /// @notice crossDomainMessenger is the L2 messenger contract address, to use the messenger, we need to add caller to the whitelist
//     address public crossDomainMessenger;

//     /// @notice DepositToL1Dealer is emitted when deposit to L1 dealer
//     /// @param amount asset amount
//     event DepositToL1Dealer(uint256 amount);

//     /// @notice initialize the contract
//     /// @param _config config contract address
//     function initialize(address _config) public initializer {
//         address[] memory _holdTokens = new address[](1);
//         _holdTokens[0] = IConfig(_config).metis();
//         __Base_init(_config, _holdTokens);
//         veMetis = config.veMetis();
//         sveMetis = config.sveMetis();
//         metis = config.metis();
//         bridge = config.bridge();
//         crossDomainMessenger = ICrossDomainEnabled(bridge).messenger();

//         /// ERC-4626 vaults that are empty or nearly empty are susceptible to a type of frontrunning attack known as a donation or inflation attack. This occurs when an attacker "donates" to the vault, artificially inflating the price of a share and putting deposits at risk of theft due to the resulting slippage.
//         /// This issue can be mitigated by making an initial deposit of a significant amount of the asset into the vault upon deployment, making price manipulation impractical.
//         /// In order to safeguard against this potential attack, we make an initial deposit into the seMetis vault.
//         _mintAndDeposit(_msgSender(), INITIAL_DEPOSIT_AMOUNT);
//     }

//     function setRewardDispatcher() public onlyOperatorOrTimeLock {
//         rewardDispatcher = config.rewardDispatcher();
//     }

//     /// @notice Mint veMETIS and deposit to seMetis vault, user will get sveMETIS
//     /// @param account account to accept sveMETIS
//     /// @param amount Metis amount
//     function mintAndDeposit(
//         address account,
//         uint256 amount
//     ) external override forUser nonReentrant {
//         _mintAndDeposit(account, amount);
//     }

//     /// @notice Mint veMETIS to user
//     /// @param account account to accept veMETIS
//     /// @param amount Metis amount
//     function mint(
//         address account,
//         uint256 amount
//     ) public override nonReentrant {
//         _mint(account, amount);
//     }

//     /// @notice Mint veMETIS from L1 as the reward
//     /// @param amount Metis amount
//     function mintFromL1(
//         uint256 amount
//     ) external override whenNotPaused nonReentrant {
//         require(amount > 0, "VeMetisMinter: amount is zero");
//         // make sure the caller is the crossDomainMessenger and is from l1Dealer
//         require(
//             _msgSender() == crossDomainMessenger,
//             "VeMetisMinter: caller is not the crossDomainMessenger"
//         );
//         require(
//             ICrossDomainMessenger(crossDomainMessenger)
//                 .xDomainMessageSender() == config.l1Dealer(),
//             "VeMetisMinter: caller is not the l1Dealer"
//         );

//         ERC20PermitPermissionedMint(veMetis).minter_mint(
//             rewardDispatcher,
//             amount
//         );
//     }

//     /// @notice Transfer Metis to L1 Dealer through the bridge
//     /// @param amount Metis amount
//     function depositToL1Dealer(uint256 amount) external payable override {
//         require(amount > 0, "VeMetisMinter: amount is zero");
//         if (IERC20(metis).allowance(address(this), bridge) < amount) {
//             IERC20(metis).approve(bridge, type(uint256).max);
//         }

//         // there are 7 days delay through the bridge
//         IL2ERC20Bridge(bridge).withdrawTo{value: msg.value}(
//             metis,
//             config.l1Dealer(),
//             amount,
//             0,
//             ""
//         );
//         emit DepositToL1Dealer(amount);
//     }

//     function _mint(address account, uint256 amount) internal {
//         require(amount > 0, "VeMetisMinter: amount is zero");
//         // user should ensure enough metis balance and allowance
//         IERC20(metis).safeTransferFrom(_msgSender(), address(this), amount);
//         ERC20PermitPermissionedMint(veMetis).minter_mint(account, amount);
//     }

//     /// @notice Mint veMetis and deposit to seMetis vault, user will get seMetis
//     /// @param account account to accept seMetis
//     /// @param amount Metis amount
//     function _mintAndDeposit(address account, uint256 amount) internal {
//         _mint(address(this), amount);
//         ERC20Upgradeable(veMetis).approve(sveMetis, amount);
//         IsveMetis(sveMetis).depositFromVeMetisMinter(amount, account);
//     }
// }
