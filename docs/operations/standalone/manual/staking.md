# Standalone (Manual)

## Staking

In order to participate in consensus, you'll need to stake (bond) your node. On TestNet you can request funds from the faucet (just reach out to us on Discord [here](https://discord.gg/guygbU4a)). On BetaNet you'll need to purchase Rowan and transfer it to the address that corresponds to the mnemonic generated earlier.

1. Log into your new node.

2. Once logged in, stake your node:

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
  --fee 100000000000000000rowan \
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
  --fee 100000000000000000rowan \
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
  --fee 100000000000000000rowan \
  --moniker my-node \
  --from my-node \
  --node tcp://rpc.sifchain.finance:80 \
  --keyring-backend file
```
