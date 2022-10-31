//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./IPossedNFT.sol";

contract PossedNFTMinter is Ownable, Pausable, ReentrancyGuard {
    /// @dev Possed NFT contract address
    address public POSSED_NFT;

    bool public isPublicSale;
    bool public isWhitelistSale;
    bool public isAirdropSale;

    /// @dev Whitelist MerkleRoot
    bytes32 public WHITELIST_ROOT = 0xe4c0da7eb8d692e5c6cd98163932cb706e3b2eebd301bd7b77c59faaec9394b1;

    /// @dev Airdrop MerkleRoot
    bytes32 public AIRDROP_ROOT = 0xe4c0da7eb8d692e5c6cd98163932cb706e3b2eebd301bd7b77c59faaec9394b1;

    /// @dev Minting Fee
    uint256 public mintingFee;

    mapping(address => bool) public airdropParticipants;
    mapping(address => bool) public whitelistParticipants;
    mapping(address => bool) public publicParticipants;

    constructor() {
        _pause();
    }

    /// @dev Set Whitelist MerkleRoot
    function setWhitelistRoot(bytes32 _root) external onlyOwner {
        WHITELIST_ROOT = _root;
    }

    /// @dev Set Airdrop MerkleRoot
    function setAirdropRoot(bytes32 _root) external onlyOwner {
        AIRDROP_ROOT = _root;
    }

    /// @dev Pause minting
    function pause() external onlyOwner {
        _pause();
    }

    /// @dev Unpause minting
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev Set Possed NFT contract address
    function setPossedNFT(address _possedNFT) external onlyOwner {
        POSSED_NFT = _possedNFT;
    }

    /// @dev Update participant data
    function _updateParticipant() private {
        if (isPublicSale) {
            publicParticipants[_msgSender()] = true;
        } else {
            if (isAirdropSale) {
                airdropParticipants[_msgSender()] = true;
            } else {
                whitelistParticipants[_msgSender()] = true;
            }
        }
    }

    /// @dev Set Minting Round configuration
    function setMintingRound(
        uint256 _fee,
        bool _isPublicSale,
        bool _isWhitelistSale,
        bool _isAirdropSale
    ) external onlyOwner {
        mintingFee = _fee;
        isPublicSale = _isPublicSale;
        isWhitelistSale = _isWhitelistSale;
        isAirdropSale = _isAirdropSale;
    }

    /// @dev Mint PSDD NFT
    function mint(bytes32[] calldata _proofs)
        external
        payable
        onlyNewParticipant
        whenNotPaused
        nonReentrant
    {
        require(mintingFee == msg.value, "Invalid Minting Fee");

        bytes32 root = isWhitelistSale ? WHITELIST_ROOT : AIRDROP_ROOT;
        if (!isPublicSale) {
            require(
                MerkleProof.verify(
                    _proofs,
                    root,
                    keccak256(abi.encodePacked(_msgSender()))
                ),
                "Not whitelisted"
            );
        }

        _updateParticipant();
        getPossedNFT().mint(_msgSender(), 1);
    }

    /// @dev Withdraw ETH from contract
    function withdrawETH(address _to) external onlyOwner {
        payable(_to).transfer(address(this).balance);
    }

    /// @dev Get Possed NFT
    function getPossedNFT() public view returns (IPossedNFT) {
        return IPossedNFT(POSSED_NFT);
    }

    modifier onlyNewParticipant() {
        bool isParticipated;
        if (isPublicSale) {
            isParticipated = publicParticipants[_msgSender()];
        } else {
            isParticipated = isAirdropSale ? airdropParticipants[_msgSender()] : whitelistParticipants[_msgSender()];
        }

        require(!isParticipated, "Already participated");
        _;
    }
}
