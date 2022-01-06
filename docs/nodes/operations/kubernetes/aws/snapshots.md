# Kubernetes

## AWS

### Restore a Snapshot

There may come a time when you need to restore your node from a snapshot. This could be for a number of reasons, but the most common is a broken upgrade.

1. Launch the wizard as described above:

```bash
make wizard
```

2. Re-deploy your sifnode with a snapshot:

```bash
CHAIN_ID=<chain_id> \
NAMESPACE=sifnode \
DOCKER_IMAGE=sifchain/sifnoded \
DOCKER_IMAGE_TAG=<chain_id> \
MONIKER=<moniker> \
SNAPSHOT_URL=<snapshot_url> \
make sifnode-kubernetes-deploy-peer-snapshot
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network your node is running on (snapshots are only currently provided for BetaNet - `sifchain-1`).|
|`<moniker>`|The moniker or name of your node as it appears on the network.|
|`<snapshot_url>`|The URL to the snapshot.|

e.g.:

```bash
CHAIN_ID=sifchain-1 \
NAMESPACE=sifnode \
DOCKER_IMAGE=sifchain/sifnoded \
DOCKER_IMAGE_TAG=sifchain-1 \
MONIKER=my-node \
SNAPSHOT_URL=https://url.to/the/snapshot \
make sifnode-kubernetes-deploy-peer-snapshot
```

Snapshots for BetaNet can be found [here](https://github.com/Sifchain/networks/blob/master/betanet/sifchain-1/snapshots.md).
