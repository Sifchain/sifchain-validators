# IBC

We welcome those validator operators who wish to participate in further decentralizing Sifchain by relaying IBC.

## Relayer

There are several options for running a relayer, including:

* [go-relayer](https://github.com/cosmos/relayer)
* [hermes](https://github.com/informalsystems/ibc-rs)
* [ts-relayer](https://github.com/confio/ts-relayer)

Sifchain recommends `hermes`. It's also recommended that you use the `hermes` template config as found [here](https://github.com/Sifchain/networks/tree/master/betanet/sifchain-1/config/ibc/hermes/config.toml).

## Channels

You can find the current list of IBC channels and networks [here](https://github.com/Sifchain/networks/tree/master/betanet/sifchain-1/ibc_channels.md).

## Nodes

When running a relayer, you will be required to run full-nodes for *all* networks you wish to relay for, in archive mode. It's recommended that you carefully study the hardware requirements for the networks in question before committing to running an IBC relayer.

## Token Registry

Sifchain maintains a token registry (whitelist) [here](https://api.sifchain.finance/tokenregistry/entries). This includes the token denoms and the channels they're allowed to be relayed over.

If you'd like to setup a completely new network (one that is not officially supported, and one which you've already configured the channels for) then please fill out the form [here](https://github.com/Sifchain/sifchain-validators/issues/new?template=ibc_chain_add.md) so we may update the token registry.
