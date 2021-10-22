# Standalone

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

## Staking

In order to participate in consensus, you'll need to stake (bond) your node. On TestNet you can request funds from the faucet (just reach out to us on Discord [here](https://discord.gg/guygbU4a)). On BetaNet you'll need to purchase Rowan and transfer it to the address that corresponds to the mnemonic generated earlier.

1. Log into your new node.

```bash
CHAIN_ID=<chain_id> make sifnode-standalone-shell
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID that your node is connected to (`sifchain-testnet-1` or `sifchain-1`).|

2. Once logged in, import your mnemonic from the previous section:

```bash
sifnoded keys add <moniker> -i --recover --keyring-backend file
```

|Param|Description|
|-----|----------|
|`<moniker>`|The moniker or name of your node as it appears on the network.|

_You will be prompted for a password. Please store this securely._

3. Stake your node:

```bash
  sifnoded tx staking create-validator \
  --commission-max-change-rate <commission_max_change_rate> \
  --commission-max-rate <commission_max_rate> \
  --commission-rate <commission_rate> \
  --amount <amount> \
  --pubkey $(sifnoded tendermint show-validator) \
  --chain-id <chain_id> \
  --min-self-delegation "1" \
  --gas <gas> \
  --gas-prices <gas_prices> \
  --moniker <moniker> \
  --from <moniker> \
  --node <node_rpc_address> \
  --keyring-backend file
```

where:

|Param|Description|
|-----|----------|
|`<commission_max_change_rate>`|The maximum commission change rate percentage (per day).|
|`<commission_max_rate>`|The maximum commission rate percentage.|
|`<commission_rate>`|The initial commission rate percentage.|
|`<chain_id>`|The chain ID of the network you are connected to (`sifchain-testnet-1` or `sifchain-1`).|
|`<moniker>`|The moniker or name of your node as you want it to appear on the network.|
|`<amount>`|The amount to stake, including the denomination (e.g.: `100000000rowan`). The precision used is 1e18.|
|`<gas>`| The per-transaction gas limit (e.g.: `300000`).|
|`<gas_prices>`|The minimum gas price to use  (e.g.: `0.5rowan`).|
|`<public_key>`|The public key of your validator.|
|`<node_rpc_address>`|The address to broadcast the transaction to (`tcp://rpc-testnet.sifchain.finance:80` for TestNet or `tcp://rpc.sifchain.finance:80`) for BetaNet.|

e.g.:

For TestNet:

```bash
  sifnoded tx staking create-validator \
  --commission-max-change-rate 0.1 \
  --commission-max-rate 0.1 \
  --commission-rate 0.1 \
  --amount 10000000rowan \
  --pubkey $(sifnoded tendermint show-validator) \
  --chain-id sifchain-testnet-1 \
  --min-self-delegation "1" \
  --gas 300000 \
  --gas-prices 0.5rowan \
  --moniker my-node \
  --from my-node \
  --node tcp://rpc-testnet.sifchain.finance:80 \
  --keyring-backend file
```

For BetaNet:

```bash
  sifnoded tx staking create-validator \
  --commission-max-change-rate 0.1 \
  --commission-max-rate 0.1 \
  --commission-rate 0.1 \
  --amount 10000000rowan \
  --pubkey $(sifnoded tendermint show-validator) \
  --chain-id sifchain-1 \
  --min-self-delegation "1" \
  --gas 300000 \
  --gas-prices 0.5rowan \
  --moniker my-node \
  --from my-node \
  --node tcp://rpc.sifchain.finance:80 \
  --keyring-backend file
```

## Support

Please join Discord [here](https://discord.gg/ePKtpunN) to join other community members running validators.
