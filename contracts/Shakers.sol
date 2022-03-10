// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";
import "./tools/StringTools.sol";

contract Shaker is ERC721, Ownable {
    using StringTools for string;

    uint256 constant MAX_SHAKERS = 1;

    uint256 ids = 0;
    uint32 public type1Free;
    uint32 public type2Free;
    uint32 public type3Free;

    // Pack values in a 32 bit structure
    struct Shaker {
        uint16 level;
        uint8 civilization;
        uint8 class;
    }

    // Structure to have possible amount to mint
    // And its value
    struct ShakerClass {
        uint256 amount;
        uint256 price;
    }
    // Each token class value and amount for minting
    ShakerClass[] public tokenAvailabilty;
    // Token ID to Shaker
    mapping(uint => Shaker) private _shakers;
    // Shaker Properties Hash to URI
    mapping(bytes32 => string) private _metadata;

    event URIChanged(bytes32 indexed);

    constructor(
        uint16[] memory _level,
        uint8[] memory _civilization,
        uint8[] memory _class,
        string[] memory _links,
        ShakerClass[] memory _mintingValues
    )  ERC721("Shaker", "SKR") {
        // Set values for how many times a class can be minted 
        // and how much user needs to pay 
        tokenAvailabilty = _mintingValues;

        // Set IPFS location for each shaker type
        for (uint i = 0; i < _level.length; i++){
            bytes32 shakerHash = getShakerHash(_level[i], _civilization[i], _class[i]);
            _metadata[shakerHash] = _links[i];
        }
    }

    function mintShaker(uint32 shakerType) external payable  {
        require(shakerType < tokenAvailabilty.length, "Invalid shaker type");

        ShakerClass storage classAvalability = tokenAvailabilty[shakerType];
        require(classAvalability.amount > 0, "No more minting for type selected");
        require(classAvalability.value <= msg.value, "Insuficient funds");

        classAvalability.amount -= 1;

        _safeMint(_msgSender(), ids);
        _shakers[ids] = primitiveShaker();

        ids += 1;
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for non existing token");

        Shaker memory playerShaker = _shakers[tokenId];
        return string(abi.encodePacked(_baseURI(), getShakerMetadataLink(playerShaker)));
    }

    function getShakerMetadataLink(Shaker memory s) internal view returns (string memory) {
        return getShakerMetadataLink(s.level, s.civilization, s.class);
    }

    function getShakerMetadataLink(
        uint16 _level, uint8 _civilization, uint8 _class
    ) public view returns (string memory) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);
        
        // Need to verifiy if that combination does exists!
        require(!_metadata[shakerHash].empty(),
            "Not valid combination of Shaker properties"
        );

        return _metadata[shakerHash];
    }

    function addShakerMetadataLink(
        uint16 _level, uint8 _civilization, uint8 _class, string calldata _link
    ) external onlyOwner validURI(_link){

        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);
        require(!_metadata[shakerHash].empty(), "There is already a link for this shaker");

       _metadata[shakerHash] = _link;
       emit URIChanged(shakerHash);
    }

    function overwriteShakerMetadataLink(
        uint16 _level, uint8 _civilization, uint8 _class, string calldata _link
    ) external onlyOwner validURI(_link) {

        bytes32 shakerHash = getShakerHash(_level, _civilization, _class);
        require(!_metadata[shakerHash].empty(), "There is no link to override for this shaker");

       _metadata[shakerHash] = _link;
       emit URIChanged(shakerHash);
    }

    // Increase shaker level, which means it has a new link in ipfs
    // If invalid level revert
    function levelUpShaker(address _player, uint16 level) external onlyOwner hasShaker(_player) {
        Shaker storage playerShaker = _shakers[_player];
        playerShaker.level = level;

        require(!getShakerMetadataLink(playerShaker).empty(),
                "Undefined Shaker properties");
    }

    // Change Shaker civilization, (new ipfs link)
    // If cannot change, revert
    function changeShakerCivilization(address _player, uint8 civilization) 
    external onlyOwner  hasShaker(_player){
        Shaker storage playerShaker = _shakers[_player];
        playerShaker.civilization = civilization;

        require(!getShakerMetadataLink(playerShaker).empty(),
                "Undefined Shaker properties");
    }

    // Set how much it is possible to free mint again
    function setFreeMinting(uint32 shakerType) public onlyOwner {}

    function _mint(address _to, uint256 _tokenId) 
    internal virtual override canHaveShaker(_to) {
        super._mint(_to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) 
    internal virtual override canHaveShaker(_to) {
        super._transfer(_from, _to, _tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function getShakerHash(
        uint16 _level, uint8 _civilization, uint8 _class
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_level, _civilization, _class));
    }

    function primitiveShaker() public pure returns(Shaker memory){
        return Shaker({
            level: 0,
            civilization: 0,
            class: 0
        });
    }

    function payOut(address payable _to, uint _transactionGas) public onlyOwner {
        (bool _sent, bytes memory _data) = _to.call{value: this.balance, gas: transactionGas}(""); 
        require(_sent, "Pay out did not occurred");
    }

    modifier canHaveShaker(address _addr){
        require(balanceOf(_addr) <= MAX_SHAKERS, "Address has already maximum number of shakers");
        _;
    }

    modifier hasShaker(address _addr){
        require(balanceOf(_addr) > 0, "Address has no shaker");
        _;
    }

    modifier validURI(string memory _link) {
        require(!_link.empty(), "Invalid URI");
        _;
    }
}
