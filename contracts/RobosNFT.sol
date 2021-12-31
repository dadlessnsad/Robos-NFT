//SPDX-License-Identifier: MIT
/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721Namable} from "./ERC721Namable.sol";
import {YieldToken} from "./YieldToken.sol";



contract RobosNFT is ERC721Namable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdTracker;


/*/////////////////////////////////////////////////////////////
                Robo Generatioin Structs
/////////////////////////////////////////////////////////////*/
    struct BreedingHistory {
        uint256 tokenId;
        uint256 time;
    }
    
    struct Robo {
        uint8 generation;
        // uint256 bornAt;
        //could be uint256 bornAt = block.timestamp; to get date of birth
    }

    enum Generation {
        GENESIS_ROBO,
        ROBO_JR
    }


/*/////////////////////////////////////////////////////////////
                      Public Vars
/////////////////////////////////////////////////////////////*/

    //Public Strings
    string public baseURI;
    string public baseExtension  = ".json";

    //Booleans True of False
    bool public paused = true; 
    bool public onlyWhitelisted = true;
    bool public breeding = false;

    //Public Addresses
    address public constant burn = address(0x000000000000000000000000000000000000dEaD);
    address payable public xurgi;
    address payable public dev = payable(0x59992E3626D6d5471D676f2de5A6e6dcF0e06De7);
    //Whitelist Addresses
    address[] public whitelistedAddresses;

    //Genesis Robo &RoboJr supply vaars
    uint256 public robosSupply; 
    uint256 public roboJrSupply;
    uint256 public roboMaxSupply = 5000;
    uint256 public roboJrMaxSupply =  2500;

    //Robo NFT Minting vars
    uint256 public mintCost;
    uint256 public BREED_PRICE = 20 ether;
    uint8 public bulkBuyLimit;
    //Whitelist NFT mint max amount
    uint8 public nftPerAddressLimit = 4;


    //Set Yeild token as RoboToken
    YieldToken public yieldToken;


/*/////////////////////////////////////////////////////////////
                        Mappings
/////////////////////////////////////////////////////////////*/
    //Tracks User Minted Amount
    mapping(address => uint256) public addressMintedBalance;
    //Tracks TokenId Breeding history
    mapping(uint256 => BreedingHistory) public breedingHistory;
    mapping(uint256 => uint256) public robosLastBreeding;
    //Maps Robos Structs
    mapping(uint256 => Robo) public roboz;
    //Tracks Balance of Genesis Robos
    mapping(address => uint256) public balanceOG;
    mapping(address => uint256) public jrCount;

/*/////////////////////////////////////////////////////////////
                        Events
/////////////////////////////////////////////////////////////*/

    event TokenMinted(uint256 tokenId, uint256 newRobo);
    event RobosPriceChanged(uint256 newMintPrice);
    event BulkBuyLimitChanged(uint256 newBulkBuyLimit);
    //event BaseURIChanged(string baseURI);

/*/////////////////////////////////////////////////////////////
                      Constructor
/////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI, string[] memory _names, uint256[] memory _ids)
        ERC721Namable(_name, _symbol, _names, _ids) {
            xurgi == _msgSender();
            setBaseURI(_initBaseURI);
            mintCost = 0.1 ether;
            bulkBuyLimit = 8;
            _preMint(25);
        }


/*/////////////////////////////////////////////////////////////
                  Internal Functions
/////////////////////////////////////////////////////////////*/
  function _baseURI() internal view virtual override returns(string memory) {
    return baseURI;
  }
    
    function _preMint(uint256 amount) internal onlyOwner {
        robosSupply = (robosSupply + amount);
        for (uint256 i = 0; i < amount; i++) {
            balanceOG[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }

    function toString(uint256 value) private pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

/*/////////////////////////////////////////////////////////////
                  Robo Minting & Token Logic
/////////////////////////////////////////////////////////////*/
    
    function mintGenesisRobo(uint256 amount) public payable {
        require(onlyWhitelisted == false, "Sale not public");
        require(amount <= bulkBuyLimit, "mint amount exceded limit");
        require((amount + robosSupply) <= roboMaxSupply);

        uint256 totalMintCost = (mintCost * amount);
        require(totalMintCost <= msg.value, "incorrect value sent");

        (bool success, ) = payable(dev).call{value: totalMintCost * 20 / 100}("");
        require(success);

        (bool transferToOwner, ) = xurgi.call{value: totalMintCost * 80 / 100}("");
        require(
            transferToOwner, "Address: unable to send value"
        );
        
        robosSupply = robosSupply + amount;

        for (uint256 i = 0; i < amount; i++) {
            yieldToken.updateRewardOnMint(msg.sender, 1);
            robosSupply = balanceOG[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }
\
    function whitelistMint(uint256 amount) public payable {
        require(onlyWhitelisted == true, "Presale over");
        require(isWhitelisted(msg.sender), "user not whitelisted");
                
        uint256 ownerMintedCount = addressMintedBalance[msg.sender];
        require(ownerMintedCount + amount <= nftPerAddressLimit, "max Witches per address for presale");

        require(amount <= bulkBuyLimit, "mint amount exceded limit");
        require((amount + robosSupply) <= roboMaxSupply);

        uint256 totalMintCost = (mintCost * amount);
        require(totalMintCost <= msg.value, "incorrect value sent");

        (bool success, ) = payable(dev).call{value: totalMintCost * 20 / 100}("");
        require(success);

        (bool transferToOwner, ) = payable(xurgi).call{value: totalMintCost * 80 / 100}("");
        require(
            transferToOwner, "Address: unable to send value"
        );
        
        robosSupply = robosSupply + amount;

        for (uint256 i = 0; i < amount; i++) {
            yieldToken.updateRewardOnMint(msg.sender, 1);
            balanceOG[msg.sender]++;
            addressMintedBalance[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }

    function _mintByGeneration(address to, Generation generation) private {
        uint8 _generation = uint8(generation);
        _tokenIdTracker.increment();
        uint256 tokenId = _tokenIdTracker.current();
        roboz[tokenId].generation = _generation;

        _safeMint(to, tokenId);

        emit TokenMinted(tokenId, roboz[tokenId].generation);
    }

    function breedRoboJr(uint256 tokenIdA,uint256 tokenIdB) external payable {
        require(breeding == true, "Breeding disabled");
        require(roboJrSupply <= roboJrMaxSupply, "supply exceeded");

        //requires msgSender to own to tokenIds 
        require(ownerOf(tokenIdA) == msg.sender, "not owner of tokenId");
        require(ownerOf(tokenIdB) == msg.sender, "not owner of tokenId");
        //requires tokenIds to be a GENESIS_ROBO
        require(roboz[tokenIdA].generation  == uint8(Generation.GENESIS_ROBO), "Can only breed Genesis Robos");
        require(roboz[tokenIdB].generation  == uint8(Generation.GENESIS_ROBO), "Can only breed Genesis Robos");

        require(robosLastBreeding[tokenIdA] + 7 days < block.timestamp, "should wait 7 days from last fuck");
        require(robosLastBreeding[tokenIdB] + 7 days < block.timestamp, "should wait 7 days from last fuck");

        require(yieldToken.balanceOf(msg.sender) >= BREED_PRICE);
        
        yieldToken.burn(msg.sender, BREED_PRICE);
    
        roboJrSupply++;

        return _breed(tokenIdA, tokenIdB);
    }

    function _breed(uint256 tokenIdA, uint256 tokenIdB) private {
        robosLastBreeding[tokenIdA] = block.timestamp;
        robosLastBreeding[tokenIdB] = block.timestamp;

        breedingHistory[tokenIdA].tokenId = tokenIdA;
        breedingHistory[tokenIdA].time = block.timestamp;

        breedingHistory[tokenIdB].tokenId = tokenIdB;
        breedingHistory[tokenIdB].time = block.timestamp;

    
        jrCount[msg.sender]++;
        _mintByGeneration(_msgSender(), Generation.ROBO_JR);
        
    }

    function changeName(uint256 tokenId, string memory newName) public override {
        yieldToken.burn(msg.sender, nameChangePrice);
        super.changeName(tokenId, newName);
    }

    function changeBio(uint256 tokenId, string memory _bio) public override {
        yieldToken.burn(msg.sender, BIO_CHANGE_PRICE);
        super.changeBio(tokenId, _bio);
    }

    function getReward() external {
        yieldToken.updateReward(msg.sender, address(0), 0);
        yieldToken.getReward(msg.sender);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        yieldToken.updateReward(from, to, tokenId);
        if (tokenId < 5001) {
            balanceOG[from]--;
            balanceOG[to]++;
        }
        ERC721.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        yieldToken.updateReward(from, to, tokenId);
        if (tokenId < 5001) {

            balanceOG[from]--;
            balanceOG[to]++;
        }
        ERC721.safeTransferFrom(from, to, tokenId, _data);
    } 

/*/////////////////////////////////////////////////////////////
                  Public view Functions
/////////////////////////////////////////////////////////////*/

    function  isWhitelisted(address _user) public view returns (bool) {
        for(uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function generationOf(uint256 tokenId) public view returns(uint8 generation) {
        return roboz[tokenId].generation;
    }

    function lastTokenId() public view returns(uint256 tokenId) {
        return _tokenIdTracker.current();
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory tokenId = toString(_tokenId);
        string memory currentBaseURI = _baseURI();
        string memory  generationPath = "/";
        uint8 generation = roboz[_tokenId].generation;
        if (generation == 0) {
            generationPath = "genesisRobo/";
        } else if (generation == 1) {
            generationPath = "roboJr/";
        }
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, generationPath, tokenId,baseExtension)) : "";    }
        

/*/////////////////////////////////////////////////////////////
                  onlyOwner Functions
/////////////////////////////////////////////////////////////*/

    function setMintCost(uint256 newMintCost) external onlyOwner {
        mintCost = newMintCost;

        emit RobosPriceChanged(newMintCost);
    }

    function setTxLimit(uint8 _bulkBuyLimit) external onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
    }

    function enableBreeding() external onlyOwner {
        breeding = true;
    }
    
    function disableBreeding() external onlyOwner {
        breeding = false;
    }

    function changeNamePrice(uint256 _price) external onlyOwner {
        nameChangePrice = _price;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;

        //emit baseuri cchanged
    }

    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    function setOnlyWhitelisted(bool _state) external onlyOwner {
        onlyWhitelisted = _state;
    }

    function setYieldToken(address _yield) external onlyOwner {
        yieldToken = YieldToken(_yield);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
  
}
