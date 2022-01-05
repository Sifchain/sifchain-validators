# IBC

We welcome those validator operators who wish to participate in further decentralizing Sifchain by relaying IBC.

## Relayer

There are several options for running a relayer, including:

* [go-relayer](https://github.com/cosmos/relayer)
* [hermes](https://github.com/informalsystems/ibc-rs)
* [ts-relayer](https://github.com/confio/ts-relayer)

Sifchain recommends `hermes`. 

## Channels

You can find the current list of IBC channels and networks [here](https://github.com/Sifchain/networks/tree/master/betanet/sifchain-1/ibc_channels.md).

## Nodes

When running a relayer, you will be required to run full-nodes for *all* networks you wish to relay for, in archive mode. It's recommended that you carefully study the hardware requirements for the networks in question before committing to running an IBC relayer.
