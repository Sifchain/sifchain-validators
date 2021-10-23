# Standalone

## Boot

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

## Terminal

To open up a new terminal session with your running node, run:

```bash
CHAIN_ID=<chain_id> make sifnode-standalone-shell
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network you want to connect to (`sifchain-testnet-1` or `sifchain-1`).|

e.g.:

For TestNet:

```bash
CHAIN_ID=sifchain-testnet-1 make sifnode-standalone-shell
```

For BetaNet:

```bash
CHAIN_ID=sifchain-1 make sifnode-standalone-shell
```

### Status

To obtain the status of your running node, run:

```bash
CHAIN_ID=<chain_id> make sifnode-standalone-status
```

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network you want to connect to (`sifchain-testnet-1` or `sifchain-1`).|

e.g.:

For TestNet:

```bash
CHAIN_ID=sifchain-testnet-1 make sifnode-standalone-status
```

For BetaNet:

```bash
CHAIN_ID=sifchain-1 make sifnode-standalone-status
```
