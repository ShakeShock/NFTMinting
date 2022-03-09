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
- `stage` a `uint8` which represents current time epoch (I think this can be scrapped)

The hash of this three properties are key to get an `ipfs` link with character attributes:

```json
{
  "health": 100,
  "damage": 10,
  "armor": 0,
  "movement_speed": 1
}
```

Characters can level up when they meet the appropiate requirements which are:

- Certain amount of experience?

Characters can move forward on stage when:

- They have the right level

Characters move to a new civilization when:

- Something Something

### Defensive Gear

It has the properties:

- prop 1

- prop 2

The metadata of defensive equipment consists of:

```json
{
  "health": +200,
  "armor": +3
}
```

### Offensive Gear

Idem description as Offensive Gear

### Misc

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
