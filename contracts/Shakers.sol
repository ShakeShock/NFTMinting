// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Shaker is ERC721, Ownable {
    uint256 constant MAX_SHAKERS = 1;
    uint256 ids = 0;

    uint32 type1Free;
    uint32 type2Free;
    uint32 type3Free;

    // Pack values in a 32 bit structure
    struct Shaker {
        uint16 level;
        uint8 civilization;
        uint8 stage;
    }

    mapping(address => Shaker) private _shakers;
    mapping(bytes32 => string) private _metadata;

    constructor(
        uint16[] memory _level,
        uint8[] memory _civilization,
        uint8[] memory _stage,
        string[] memory _links,
        uint32 maxFreeMinting
    )  ERC721("Shaker", "SKR") {
        // Set IPFS location for each shaker type
        type1Free = maxFreeMinting * 70 / 100;
        type2Free = maxFreeMinting * 20 / 100;
        type3Free = maxFreeMinting * 10 / 100;

        for (uint i = 0; i < _level.length; i++){
            bytes32 shakerHash = getShakerHash(_level[i], _civilization[i], _stage[i]);
            _metadata[shakerHash] = _links[i];
        }
    }

    function mintShaker(uint32 shakerType) external payable {
       address sender = _msgSender();
       require(balanceOf(sender) < MAX_SHAKERS, "Already owns maximum number of shakers");         
       safeMint(sender, ids);
    }

    function safeMint(address sender, uint32 shakerType) internal payable {
        _safeMint(sender, ids);

        if (msg.value == 0){
            if (shakerType == 1){
                require(type1Free > 0, "No more type one free");
                type1Free -= 1;
            }
            if (shakerType == 2){
                require(type1Free > 0, "No more type two free");
                type2Free -= 1;
            }
            if (shakerType == 3){
                require(type1Free > 0, "No more type three free");
                type3Free -= 1;
            }
        } else {
            if (shakerType == 1)
                require(msg.value > 0.015 ether, "Insuficient funds");
            if (shakerType == 2)
                require(msg.value > 0.03 ether, "Insuficient funds");
            if (shakerType == 3)
                require(msg.value > 0.06 ether, "Insuficient funds");
        }
        _shakers[sender] = primitiveShaker();

        ids += 1;

        
    }

    function tokenURI() public view returns (string memory) {
        address sender = _msgSender();
        require(balanceOf(sender) == 1, "Player does not own a Shaker");

        Shaker memory playerShaker = _shakers[sender];

        return string(abi.encodePacked(_baseURI(), getShakerMetadataLink(playerShaker)));
    }

    function getShakerMetadataLink(Shaker memory s) internal view returns (string memory) {
        return getShakerMetadataLink(s.level, s.civilization, s.stage);
    }

    function getShakerMetadataLink(
        uint16 _level, uint8 _civilization, uint8 _stage
    ) public view returns (string memory) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _stage);
        
        // Need to verifiy if that combination does exists!
        require (
            keccak256(abi.encode(_metadata[shakerHash])) != keccak256(abi.encode("")),
            "Not valid combination of Shaker properties"
        );

        return _metadata[shakerHash];
    }

    function getShakerHash(
        uint16 _level, uint8 _civilization, uint8 _stage
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_level, _civilization, _stage));
    }

    function setShakerMetadataLink(
        uint16 _level, uint8 _civilization, uint8 _stage, string calldata _link
    ) external onlyOwner {
        require(keccak256(abi.encode(_link)) != keccak256(abi.encode("")), "Link cannot be empty");
        bytes32 shakerHash = getShakerHash(_level, _civilization, _stage);

       _metadata[shakerHash] = _link;
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

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function primitiveShaker() public pure returns(Shaker memory){
        return Shaker({
            level: 0,
            civilization: 0,
            stage: 0
        });
    }
}
