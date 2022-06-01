 pragma solidity ^0.8.14;

// SPDX-License-Identifier: MIT

import "../openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../openzeppelin-contracts/contracts/interfaces";
import "../openzeppelin-contracts/contracts/access/contracts/access/Ownable.sol";


/**
 * @title Sample NFT contract
 * @dev Extends ERC-721 NFT contract and implements ERC-2981
 */

 contract Token is ERC721, Ownable, ERC721Enumerable, ERC721URIStorage, ERC721Burnable {    
    
    address private _recipient;    
    uint256 totalNFT = 121;   
    uint256 public royaltyonsecondarysale = 10;
    uint256 public DanielleWeberartistshare = 80;
    uint256 public CollingsNFTshare = 15;    
    uint256 public constant DanielleWeberartistroyaltiesPercentage = 85;
    uint256 public constant  CollingsNFTroyaltiesPercentage = 15;

    address public DanielleWeberartist = address(0xdE2de1d9DEADC8C2b74ad7c39078824048458B01);
    address public CollingsNFT = address(0x64024942fa38486b375FbaE3a01f767CC47Fcb2f);  
    
    mapping (address => uint256) public freeMinters;   

     // Keep a mapping of token ids and corresponding IPFS hashes
    mapping(string => uint8) hashes;
    // Maximum amounts of mintable tokens
    uint256 public constant MAX_SUPPLY = 121;
    // Address of the royalties recipient
    address private _royaltiesReceiver;
    // Percentage of each sale to pay as royalties
    uint256 public constant royaltiesPercentage = 10;

    // Events
    event Mint(uint256 tokenId, address recipient);
    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

constructor(address initialRoyaltiesReceiver,address whitelistContract) ERC721("Collins NFT", "CFT") {
         Owner = msg.sender;
         whitelist = IWhitelist(whitelistContract);
        _royaltiesReceiver = initialRoyaltiesReceiver;
    }

/**
    * @dev startPresale starts a presale for the whitelisted addresses
      */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        // Set presaleEnded time as current timestamp + 5 minutes
        // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 5 minutes;
    }

     /**
      * @dev presaleMint allows an user to mint one NFT per transaction during the presale.
      */
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Cypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }

     /**
    * @dev mint allows an user to mint 1 NFT per transaction after the presale has ended.
    */
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Cypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }
/**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

 /**
    * @dev setPaused makes the contract paused or unpaused
      */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }
    function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public onlyOwner{
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);
    openingTime = _openingTime;
    closingTime = _closingTime;
  }


   /**
    * @dev withdraw sends all the ether in the contract
    * to the owner of the contract
      */
    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

      // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}          

 
