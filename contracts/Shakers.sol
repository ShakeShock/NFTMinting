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

    // Token ID to Shaker
    mapping(uint => Shaker) private _shakers;
    // Shaker Properties Hast to URI
    mapping(bytes32 => string) private _metadata;

    event URIChanged(bytes32 indexed);

    constructor(
        uint16[] memory _level,
        uint8[] memory _civilization,
        uint8[] memory _class,
        string[] memory _links,
        uint32 maxFreeMinting
    )  ERC721("Shaker", "SKR") {
        // Set free minting
        type1Free = maxFreeMinting * 70 / 100;
        type2Free = maxFreeMinting * 20 / 100;
        type3Free = maxFreeMinting * 10 / 100;

        // Set IPFS location for each shaker type
        for (uint i = 0; i < _level.length; i++){
            bytes32 shakerHash = getShakerHash(_level[i], _civilization[i], _class[i]);
            _metadata[shakerHash] = _links[i];
        }
    }

    function mintShaker(uint32 shakerType) external payable  {
        require(shakerType <= 2, "Invalid shaker type");

        // require(balanceOf(sender) < MAX_SHAKERS, "Already owns maximum number of shakers");

        if (msg.value == 0){
            if (shakerType == 0){
                require(type1Free > 0, "No more type one free");
                type1Free -= 1;
            }
            if (shakerType == 1){
                require(type2Free > 0, "No more type two free");
                type2Free -= 1;
            }
            if (shakerType == 2){
                require(type3Free > 0, "No more type three free");
                type3Free -= 1;
            }
        } else {
            if (shakerType == 0)
                require(msg.value > 0.015 ether, "Insuficient funds");
            if (shakerType == 1)
                require(msg.value > 0.03 ether, "Insuficient funds");
            if (shakerType == 2)
                require(msg.value > 0.06 ether, "Insuficient funds");
        }

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
    function levelUpShaker() external {}

    // Change Shaker civilization, (new ipfs link)
    // If cannot change, revert
    function changeShakerCivilization() private {}

    // Upgrade stage, (new ipfs link)
    // If cannot further advance then revert
    function increaseShakerStage() private {}

    // Set how much it is possible to free mint again
    function setFreeMinting(uint32 shakerType) public onlyOwner {}

    function _mint(address to, uint256 tokenId) 
    internal virtual override canHaveShaker(to) {
        super._mint(to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) 
    internal virtual override canHaveShaker(to) {
        super._transfer(from, to, tokenId);
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

    modifier canHaveShaker(address addr){
        require(balanceOf(addr) <= MAX_SHAKERS, "Address has already maximum number of shakers");
        _;
    }

    modifier validURI(string memory _link) {
        require(!_link.empty(), "Invalid URI");
        _;
    }
}
