// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ShakerNFT is ERC721, Ownable {
    uint constant MAX_SHAKERS = 1;
    uint ids = 0;

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
        string[] memory _links
    )  ERC721("Shaker", "SKR") {
        // Set IPFS location for each shaker type
        for (uint i = 0; i < _level.length; i++){
            bytes32 shakerHash = getShakerHash(_level[i], _civilization[i], _stage[i]);
            _metadata[shakerHash] = _links[i];
        }
    }

    function mintShaker(uint _characterIndex) external {
        // Need to fix minting, how this contract mapping
        // plays along with oppenzeppelin's

       address sender = _msgSender();
       require(balanceOf(sender) < MAX_SHAKERS, "Already owns maximum number of shakers");         

       _safeMint(sender, ids);

       _shakers[sender] = primitiveShaker();
       ids += 1;
    }

    function getPlayerShakerMetata() public view returns (string memory) {
        address sender = _msgSender();
        require(balanceOf(sender) == 1, "Player does not own a Shaker");

        Shaker memory playerShaker = _shakers[sender];

        return getShakerMetada(playerShaker.level, playerShaker.civilization, playerShaker.stage);
    }

    function getShakerMetada(
        uint16 _level, uint8 _civilization, uint8 _stage
    ) public view returns (string memory) {
        bytes32 shakerHash = getShakerHash(_level, _civilization, _stage);
        
        // Need to verifiy if that combination does exists!
        require (_metadata[shakerHash] != "", "Not valid combination of Shaker properties");

        return _metadata[shakerHash];
    }

    function getShakerHash(
        uint16 _level, uint8 _civilization, uint8 _stage
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_level, _civilization, _stage));
    }

    function setShakerMetadata(
        uint16 _level, uint8 _civilization, uint8 _stage, string calldata _link
    ) external onlyOwner {
        require(link != "", "Link cannot be empty");
        bytes32 shakerHash = getShakerHash(_level, _civilization, _stage);

       _metadata[shakerHash] = _link;
    }

    function primitiveShaker() public pure returns(Shaker memory){
        return Shaker({
            level: 0,
            civilization: 0,
            stage: 0
        });
    }
}
