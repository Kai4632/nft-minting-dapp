// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMinter is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    uint256 public mintPrice = 0.01 ether;
    uint256 public maxSupply = 1000;
    bool public mintingEnabled = true;
    
    struct NFTMetadata {
        string name;
        string description;
        string imageURI;
        string tokenURI;
    }
    
    mapping(uint256 => NFTMetadata) public tokenMetadata;
    
    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI);
    
    constructor() ERC721("Simple NFT Collection", "SNFT") {
        _tokenIds.increment(); // Start from token ID 1
    }
    
    function mintNFT(
        string memory _name,
        string memory _description,
        string memory _imageURI,
        string memory _tokenURI
    ) public payable returns (uint256) {
        require(mintingEnabled, "Minting is currently disabled");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(_tokenIds.current() <= maxSupply, "Max supply reached");
        
        uint256 newTokenId = _tokenIds.current();
        _tokenIds.increment();
        
        _mint(msg.sender, newTokenId);
        
        tokenMetadata[newTokenId] = NFTMetadata({
            name: _name,
            description: _description,
            imageURI: _imageURI,
            tokenURI: _tokenURI
        });
        
        emit NFTMinted(msg.sender, newTokenId, _tokenURI);
        
        return newTokenId;
    }
    
    function getTokenMetadata(uint256 _tokenId) public view returns (NFTMetadata memory) {
        require(_exists(_tokenId), "Token does not exist");
        return tokenMetadata[_tokenId];
    }
    
    function setMintPrice(uint256 _newPrice) public onlyOwner {
        mintPrice = _newPrice;
    }
    
    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        maxSupply = _newMaxSupply;
    }
    
    function toggleMinting() public onlyOwner {
        mintingEnabled = !mintingEnabled;
    }
    
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
    function getTotalMinted() public view returns (uint256) {
        return _tokenIds.current() - 1;
    }
} 