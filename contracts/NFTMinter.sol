// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTMinter is ERC721Upgradeable, ERC721URIStorageUpgradeable {
    uint256 private _tokenIds;


    struct mintedNft {
        uint256 nftId;
        uint256 token_id;
    }

    mapping(address => mintedNft[]) internal mints;
    mapping(address => bool) public eligibleAddresses;

    modifier onlyEligible() {
        require(eligibleAddresses[msg.sender], "Address is not eligible for minting");
        _;
    }

    function initialize() initializer public {
        __ERC721_init("Velix SuperStar NFT", "VSNFT");
    }

    function addEligibleAddress(address _address) external{
        eligibleAddresses[_address] = true;
    }

    function mintsByUser(address user) public view returns (mintedNft[] memory) {
        return mints[user];
    }

    function safeMint(address to, uint256 nftId, string memory uri) public onlyEligible {
        require(to == msg.sender, "You can't mint this NFT");

        _tokenIds++;

        _mint(to, _tokenIds);

        _setTokenURI(_tokenIds, uri);

        mints[to].push(mintedNft(nftId, _tokenIds));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId); 
    }
}