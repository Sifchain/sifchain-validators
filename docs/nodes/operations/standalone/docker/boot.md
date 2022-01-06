# Standalone

## Docker

### Boot

To boot your container, run:

```bash
CHAIN_ID=<chain_id> make sifnode-standalone-boot
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network you want to connect to (`sifchain-testnet-1` or `sifchain-1`).|

e.g.:

For TestNet:

```bash
CHAIN_ID=sifchain-testnet-1 make sifnode-standalone-boot
```

For BetaNet:

```bash
CHAIN_ID=sifchain-1 make sifnode-standalone-boot
```
