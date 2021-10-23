#!/bin/sh
#
# Sifchain: Entry point script.
#

#
# Configure the node.
#
setup() {
  sifgen node create "$CHAIN_ID" "$MONIKER" "$MNEMONIC" --peer-address "$PEER_ADDRESSES" --genesis-url "$GENESIS_URL" --bind-ip-address "$BIND_IP_ADDRESS" --with-cosmovisor
}

#
# Cleanup.
#
cleanup() {
  rm -rf "${HOME}"/.sifnoded/keyring*
}

#
# Run the node under cosmovisor.
#
run() {
  cosmovisor start --rpc.laddr tcp://0.0.0.0:26657 --minimum-gas-prices "$GAS_PRICE"
}

if [ ! -f "${HOME}"/.sifnoded/config/genesis.json ]; then
  setup
fi

cleanup
run
