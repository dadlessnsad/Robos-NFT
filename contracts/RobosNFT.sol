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
import {BoltsToken} from "./BoltsToken.sol";

contract RobosNFT is ERC721Namable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdTracker;

/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    Robo Generatioin Structs
///////////////////////////////////////////////////////////////////////////////////////////////*/  
    struct ManufactureHistory {
        uint256 tokenId;
        uint256 time;
    }

    struct Robo {
        uint8 generation;
    }

    enum Generation {
        GENESIS_ROBO,
        ROBO_JR
    }

/*///////////////////////////////////////////////////////////////////////////////////////////////
                                        Public Vars
///////////////////////////////////////////////////////////////////////////////////////////////*/  
    //Public Strings
    string public baseURI;
    string public baseExtension  = ".json";

    // Booleans
    bool public paused = true; 
    bool public preSale = true;
    bool public breeding = false;

    //Public Addresses
    address public constant burn = address(0x000000000000000000000000000000000000dEaD);
    address payable public xurgi = payable(0x4BE50DAF1339DA3dA8dDC130F8CE54Aa10eF2dc6);
    address[] public whitelistedAddresses;

    // Minting Variables
    // Whitelist Max per wallet kinda easy to get past tho
    uint16 public nftPerAddress = 2;
    uint16 public bulkBuyLimit;
    uint256 public price;
    uint256 public MANUFACTURE_PRICE = 20 ether;

    //Genesis Robo &RoboJr supply vaars
    uint256 public robosSupply; 
    uint256 public roboJrSupply;
    uint256 public roboMaxSupply = 5000;
    uint256 public roboJrMaxSupply =  2500;

    //Set Yeild token as RoboToken
    BoltsToken public boltsToken;
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                        Mappings
///////////////////////////////////////////////////////////////////////////////////////////////*/
    mapping(address => uint256) public addressMintedBalance;
    mapping(address => uint256) public balanceOG;
    mapping(address => uint256) public balanceJR;
    mapping(uint256 => ManufactureHistory) public manufactureHistory;
    mapping(uint256 => Robo) public roboz ;
    mapping(uint256 => uint256) public robosManufacture ;
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                        Events
///////////////////////////////////////////////////////////////////////////////////////////////*/

/*///////////////////////////////////////////////////////////////////////////////////////////////
                                        Constructor
///////////////////////////////////////////////////////////////////////////////////////////////*/
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string[] memory _names,
        uint256[] memory _ids
    ) ERC721Namable(_name, _symbol, _names, _ids) {
        xurgi == _msgSender();
        setBaseURI(_initBaseURI);
        price = 0.1 ether;
        bulkBuyLimit = 8;
        _preMint(60);
    }

/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    Modifier Functions
///////////////////////////////////////////////////////////////////////////////////////////////*/
    modifier unPaused() {
        require(
            paused == false,
            "Contract Paused"
        );
        _;
    }
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    External Functions
///////////////////////////////////////////////////////////////////////////////////////////////*/  
    function manufactureRoboJr(uint256 tokenIdA, uint256 tokenIdB) external payable unPaused() {
        require(breeding == true, "Breeding disabled");
        require(roboJrSupply <= roboJrMaxSupply, "supply exceeded");

        //requires msgSender to own to tokenIds 
        require(ownerOf(tokenIdA) == msg.sender, "not ownerOf");
        require(ownerOf(tokenIdB) == msg.sender, "not ownerOf");
        //requires tokenIds to be a GENESIS_ROBO
        require(roboz[tokenIdA].generation  == uint256(Generation.GENESIS_ROBO), "Can only breed GenesisRobos");
        require(roboz[tokenIdB].generation  == uint256(Generation.GENESIS_ROBO), "Can only breed GenesisRobos");

        require(robosManufacture[tokenIdA] + 7 days < block.timestamp, "wait 7 days");
        require(robosManufacture[tokenIdB] + 7 days < block.timestamp, "wait 7 days");

        require(boltsToken.balanceOf(msg.sender) >= MANUFACTURE_PRICE);
        
        boltsToken.burn(msg.sender, MANUFACTURE_PRICE);
    
        roboJrSupply++;

        return _manufacture(tokenIdA, tokenIdB);
    }

    function getReward() external unPaused() {
        boltsToken.updateReward(msg.sender, address(0), 0);
        boltsToken.getReward(msg.sender);
    }

     function setMintCost(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }

    function setTxLimit(uint16 _bulkBuyLimit) external onlyOwner {
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
    }

    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner {
        delete whitelistedAddresses;
        whitelistedAddresses = _users;
    }

    function setOnlyPreSale(bool _state) external onlyOwner {
        preSale = _state;
    }

    function setBoltsToken(address _yield) external onlyOwner {
        boltsToken = BoltsToken(_yield);
    }

/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    Public Mint/Breed Functions
///////////////////////////////////////////////////////////////////////////////////////////////*/
        function mintGenesisRobo(uint256 amount) public payable unPaused() {
        require(preSale == false, "Sale not public");
        require(amount <= bulkBuyLimit, "amount exceded limit");
        require((amount + robosSupply) <= roboMaxSupply);

        uint256 total = (price * amount);
        require(total <= msg.value, "incorrect value");
        
        (bool transferToDaoStatus, ) = xurgi.call{value: total}("");
        require(
            transferToDaoStatus,
            "Address: unable to send value."
        );

        robosSupply = robosSupply + amount;
        for (uint256 i = 0; i < amount; i++) {
            boltsToken.updateRewardOnMint(msg.sender, 1);
            balanceOG[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }

    function whitelistMint(uint256 amount) public payable unPaused(){
        require(paused == false, "Paused");
        require(preSale == true, "preSale over");
        require(isWhitelisted(msg.sender), "not whitelisted");
                
        uint256 mintedCount = addressMintedBalance[msg.sender];
        require(mintedCount + amount <= nftPerAddress, "max per address");
        require(amount <= bulkBuyLimit, "amount exceded limit");
        require((amount + robosSupply) <= roboMaxSupply);

        uint256 total = (price * amount);
        require(total <= msg.value, "incorrect value");
        
        (bool transferToDaoStatus, ) = xurgi.call{value: total}("");
        require(
            transferToDaoStatus,
            "Address: unable to send value."
        );

        robosSupply = robosSupply + amount;
        for (uint256 i = 0; i < amount; i++) {
            boltsToken.updateRewardOnMint(msg.sender, 1);
            balanceOG[msg.sender]++;
            addressMintedBalance[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }
    
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    Public View Functions
///////////////////////////////////////////////////////////////////////////////////////////////*/
    function changeName(uint256 tokenId, string memory newName) public override {
        boltsToken.burn(msg.sender, nameChangePrice);
        super.changeName(tokenId, newName);
    }

    function changeBio(uint256 tokenId, string memory _bio) public override {
        boltsToken.burn(msg.sender, BIO_CHANGE_PRICE);
        super.changeBio(tokenId, _bio);
    }
    
    function  isWhitelisted(address _user) public view returns (bool) {
        for(uint i = 0; i < whitelistedAddresses.length; i++) {
            if (whitelistedAddresses[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function generationOf(uint256 tokenId) public view returns(uint256 generation) {
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
        uint256 generation = roboz[_tokenId].generation;
        if (generation == 0) {
            generationPath = "genesisRobo";
        } else if (generation == 1) {
            generationPath = "roboJr";
        }
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, generationPath, tokenId, baseExtension)) : "";    
    }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override {
        boltsToken.updateReward(from, to, tokenId);
        if (tokenId < 5001) {
            balanceOG[from]--;
            balanceOG[to]++;
        }
        ERC721.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to, 
        uint256 tokenId, 
        bytes memory _data
    ) public override {
        boltsToken.updateReward(from, to, tokenId);
        if (tokenId < 5001) {

            balanceOG[from]--;
            balanceOG[to]++;
        }
        ERC721.safeTransferFrom(from, to, tokenId, _data);
    } 
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    Internal functions
///////////////////////////////////////////////////////////////////////////////////////////////*/
    function _baseURI() internal view virtual override returns(string memory) {
        return baseURI;
    }
    
/*///////////////////////////////////////////////////////////////////////////////////////////////
                                    private functions
///////////////////////////////////////////////////////////////////////////////////////////////*/ 
    function _preMint(uint256 amount) private {
        robosSupply = robosSupply + amount;
        for (uint256 i = 0; i < amount; i++) {
            balanceOG[msg.sender]++;
            _mintByGeneration(_msgSender(), Generation.GENESIS_ROBO);
        }
    }
    
    function _mintByGeneration(address to, Generation generation) private {
        uint8 _generation = uint8(generation);
        _tokenIdTracker.increment();
        uint256 tokenId = _tokenIdTracker.current();
        roboz[tokenId].generation = _generation;

        _safeMint(to, tokenId);
    }

    function _manufacture(uint256 tokenIdA, uint256 tokenIdB) private {
        robosManufacture[tokenIdA] = block.timestamp;
        robosManufacture[tokenIdB] = block.timestamp;

        manufactureHistory[tokenIdA].tokenId = tokenIdA;
        manufactureHistory[tokenIdA].time = block.timestamp;

        manufactureHistory[tokenIdB].tokenId = tokenIdB;
        manufactureHistory[tokenIdB].time = block.timestamp;

    
        balanceJR[msg.sender]++;
        _mintByGeneration(_msgSender(), Generation.ROBO_JR);
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

}
