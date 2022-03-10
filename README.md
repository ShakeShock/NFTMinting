# ShakeShock Minting Contract

## Contracts

There are going to be three types of NFT, all following ERC721 standard:

- Shaker which represents a character. Only only one character per address (half-implemented)
- Defensive Gear which represents armor equipped by the character (not implemented)
- Offensive Gear which represents swords, bows, equipped by the character (not implemented)

### Shaker

It has the properties:

- `level` a `uint16` which represents character level (from 0 to 3)
- `civilization` a `uint8` which represents the civilization it belongs

The hash of this three properties are key to get an `ipfs` link with character attributes:

```json
{
  "health": 100,
  "damage": 10,
  "armor": 0,
  "speed": 1
}
```

Characters can level up when they meet the appropiate requirements:

- A minimum level of Experience (XP points)
- A minimum amount of $SHAKE


Characters move to a new civilization when:

- A minimum level of metadata from character and equipment
- A minimum amount of $SHAKE

### Defensive Gear

It has the properties:

- Can add and/or substrack integers from the character metadata when applied

- It's not unique. Can exist multiple times and have multiple owners

The metadata of defensive equipment consists of:

```json
{
  "health": +20,
  "damage": 0,
  "armor": +20,
  "speed": +1
}
```

### Offensive Gear

It has the properties:

- Can add and/or substrack integers from the character metadata when applied

- It's not unique. Can exist multiple times and have multiple owners

The metadata of defensive equipment consists of:

```json
{
  "health": +20,
  "damage": +3,
  "armor": 0,
  "speed": -1
}
```
```
### Misc

Maybe in the future you can also craft the equipment to increase the metadata by exchanging some $SHAKE

Leaving this hardhat stuff here for now:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
