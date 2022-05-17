# Standalone (Docker)

## Launch

To configure and launch your node:

```bash
CHAIN_ID=<chain_id> make sifnode-standalone-wizard
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network you want to connect to (`sifchain-testnet-1` or `sifchain-1`).|

e.g.:

For TestNet:

```bash
CHAIN_ID=sifchain-testnet-1 make sifnode-standalone-wizard
```

For BetaNet:

```bash
CHAIN_ID=sifchain-1 make sifnode-standalone-wizard
```

_Please remember to securely store your mnemonic that is shown to you during the setup of your node!_

## Support

Please join Discord [here](https://discord.gg/sifchain) to join other community members running validators.
