// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

// /// @title Velix
// /// @notice veMetis is the ERC20 token that represents the staked Velix Metis
// /** @notice Combines Openzeppelin's ERC20Permit and ERC20Burnable with Ownable2Step
//     Also includes a list of authorized minters */
// /// @dev veMetis adheres to EIP-712/EIP-2612 and can use permits
// contract VeMetis is ERC20Permit,
//     ERC20Burnable,
//     Ownable2Step {
    
//     // Core
//     address public timelock_address;

//     // Minters
//     address[] public minters_array; // Allowed to mint
//     mapping(address => bool) public minters; // Mapping is also used for faster verification

//     /* ========== CONSTRUCTOR ========== */

//     /// @notice construct the contract
//     /// @param timelock timelock contract address
//     /* ========== CONSTRUCTOR ========== */

//     constructor(
//         address _timelock
//     ) 
//     ERC20("Velix Metis", "veMETIS")
//     ERC20Permit("Velix Metis") 
//     {
//       timelock_address = _timelock;
//     }


//     /* ========== MODIFIERS ========== */

//     modifier onlyByOwnGov() {
//         require(msg.sender == timelock_address || msg.sender == owner(), "Not owner or timelock");
//         _;
//     }

//     modifier onlyMinters() {
//        require(minters[msg.sender] == true, "Only minters");
//         _;
//     } 

//     /* ========== RESTRICTED FUNCTIONS ========== */

//     // Used by minters when user redeems
//     function minter_burn_from(address b_address, uint256 b_amount) public onlyMinters {
//         _burn(b_address, b_amount);
//         emit TokenMinterBurned(b_address, msg.sender, b_amount);
//     }

//     // This function is what other minters will call to mint new tokens 
//     function minter_mint(address m_address, uint256 m_amount) public onlyMinters {
//         super._mint(m_address, m_amount);
//         emit TokenMinterMinted(msg.sender, m_address, m_amount);
//     }

//     // Adds whitelisted minters 
//     function addMinter(address minter_address) public onlyByOwnGov {
//         require(minter_address != address(0), "Zero address detected");

//         require(minters[minter_address] == false, "Address already exists");
//         minters[minter_address] = true; 
//         minters_array.push(minter_address);

//         emit MinterAdded(minter_address);
//     }

//     // Remove a minter 
//     function removeMinter(address minter_address) public onlyByOwnGov {
//         require(minter_address != address(0), "Zero address detected");
//         require(minters[minter_address] == true, "Address nonexistant");
        
//         // Delete from the mapping
//         delete minters[minter_address];

//         // 'Delete' from the array by setting the address to 0x0
//         for (uint i = 0; i < minters_array.length; i++){ 
//             if (minters_array[i] == minter_address) {
//                 minters_array[i] = address(0); // This will leave a null in the array and keep the indices the same
//                 break;
//             }
//         }

//         emit MinterRemoved(minter_address);
//     }

//     function setTimelock(address _timelock_address) public onlyByOwnGov {
//         require(_timelock_address != address(0), "Zero address detected"); 
//         timelock_address = _timelock_address;
//         emit TimelockChanged(_timelock_address);
//     }

//     /* ========== EVENTS ========== */
    
//     event TokenMinterBurned(address indexed from, address indexed to, uint256 amount);
//     event TokenMinterMinted(address indexed from, address indexed to, uint256 amount);
//     event MinterAdded(address minter_address);
//     event MinterRemoved(address minter_address);
//     event TimelockChanged(address timelock_address);
// }