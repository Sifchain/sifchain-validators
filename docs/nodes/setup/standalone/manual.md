# Standalone (Manual)

## Prerequisites / Dependencies:

- Clone the repository (`git clone https://github.com/Sifchain/sifnode.git`)
- [Golang 1.16+](https://golang.org/doc/install)

## sifnoded

### TestNet

To compile and install, run:

```console
git checkout mainnet-0.9.0 && make clean install
```

### BetaNet

#### Archive node

To compile and install, run:

```console
git checkout mainnet-0.9.0 && make clean install
```

#### Non-archive node

To compile and install, run:

```console
git checkout v0.13.3 && make clean install
```

## cosmovisor

`cosmovisor` is a small process manager for Cosmos SDK application binaries that monitors the governance module for incoming chain upgrade proposals.

To install, run:

```console
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
```

## Setup

1. Setup `cosmovisor`:

```console
mkdir -p "${HOME}"/.sifnoded/cosmovisor/genesis/bin
mkdir "${HOME}"/.sifnoded/cosmovisor/upgrades
cp "${GOPATH}"/bin/sifnoded "${HOME}"/.sifnoded/cosmovisor/genesis/bin
```

2. Add the `cosmovisor` environment variables (recommend you set these up to be added when the instance boots):

```console
export DAEMON_HOME="${HOME}"/.sifnoded
export DAEMON_RESTART_AFTER_UPGRADE=true
export DAEMON_ALLOW_DOWNLOAD_BINARIES=false
export DAEMON_NAME=sifnoded
export UNSAFE_SKIP_BACKUP=true
```

If you wish to manually download and install new binaries each time an upgrade is issued, then please set:

```console
export DAEMON_ALLOW_DOWNLOAD_BINARIES=false
```

3. Initialize your node:

```console
sifnoded init <moniker> --chain-id <chain_id>
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network you want to connect to (`sifchain-testnet-1` or `sifchain-1`).|
|`<moniker>`|The moniker or name of your node as it appears on the network.|

e.g.:

For TestNet:

```console
sifnoded init my-node --chain-id sifchain-testnet-1
```

For BetaNet:

```console
sifnoded init my-node --chain-id sifchain-1
```

3. Download the latest genesis.

For TestNet:

```console
cd "${HOME}"/.sifnoded/config
wget -O genesis.json.gz https://raw.githubusercontent.com/Sifchain/networks/master/testnet/sifchain-testnet-1/genesis.json.gz
gunzip genesis.json.gz
```

For BetaNet:

```console
cd "${HOME}"/.sifnoded/config
wget -O genesis.json.gz https://raw.githubusercontent.com/Sifchain/networks/master/betanet/sifchain-1/genesis.json.gz
gunzip genesis.json.gz
```

4. Setup the persistent peers:

For TestNet:

```console
sed -i "s/persistent_peers =.*/persistent_peers = \"c4140c5547066193bd20765a8050e5642d2a02ff@54.85.39.193:26656,7045afb6dcf9f301b29dfb08e08939b3c3fa74a6@54.211.41.96:26656,ff6481468368fcb14c657e0079e7791599710be7@54.162.2.255:26656,3fb84bf0d31e7ee8c512b0e6f82fbba7051f3f1f@54.158.121.186:26656\"/g" "${HOME}"/.sifnoded/config/config.toml
```

For BetaNet:

```console
sed -i "s/persistent_peers =.*/persistent_peers = \"0d4981bdaf4d5d73bad00af3b1fa9d699e4d3bc0@44.235.108.41:26656,bcc2d07a14a8a0b3aa202e9ac106dec0bef91fda@13.55.247.60:26656,663dec65b754aceef5fcccb864048305208e7eb2@34.248.110.88:26656,0120f0a48e7e81cc98829ef4f5b39480f11ecd5a@52.76.185.17:26656\"/g" "${HOME}"/.sifnoded/config/config.toml
```

5. Setup the external address:

```console
sed -i -e "s/external_address = \"\"/external_address = \"<bind_ip_address>:26656\"/g" "${HOME}"/.sifnoded/config/config.toml
```

Where:

|Param|Description|
|-----|----------|
|`<bind_ip_address>`|The IP Address to bind to (Important: this is what your node will advertise to the rest of the network). This should be the public IP of the host.|

e.g.:

```console
sed -i -e "s/external_address = \"\"/external_address = \"1.23.45.56:26656\"/g" "${HOME}"/.sifnoded/config/config.toml
```

## Snapshot

Currently only BetaNet has snapshots available, for non-archive nodes. An archive node on BetaNet or a full node on TestNet will sync from genesis.

Download the latest snapshot:

```console
snapshot=$(echo "sifchain_$(TZ=GMT date +'%Y-%m-%d').tar")
cd "${HOME}"/.sifnoded/data
wget -O sifchain.tar http://135.181.60.250:8081/sifchain/"${snapshot}"
```

and then unpack as follows:

```console
tar -xvf sifchain.tar
```

## Start

### TestNet

```console
cosmovisor start
```

### BetaNet

#### Archive node

```console
cosmovisor start --pruning nothing
```

#### Non-archive node

```console
cosmovisor start
```

It's *highly* recommended that you consider running `cosmovisor` under `systemd` or `supervisord`, or some other process control system of your choosing.

## Stake

In order to participate in consensus, you'll need to stake your node. Please see [here](https://github.com/Sifchain/sifchain-validators/tree/master/docs/nodes/operations/standalone/manual/staking.md) for instructions on how to stake.
