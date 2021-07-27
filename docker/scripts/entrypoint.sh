#!/bin/sh
#
# Sifchain: Entrypoint.
#

#
# Configure the node.
#
setup() {
  sifgen node create "$CHAINNET" "$MONIKER" "$MNEMONIC" --peer-address "$PEER_ADDRESSES" --genesis-url "$GENESIS_URL" --bind-ip-address "$BIND_IP_ADDRESS" --with-cosmovisor
}

#
# Upgrade the node.
#
upgrade() {
  case $CHAINNET in
    *"testnet"*)
      PREFIX="testnet"
      ;;
    *)
      PREFIX="mainnet"
      ;;
  esac

  # Download the upgrade.
  mkdir -p "${HOME}"/.sifnoded/cosmovisor/upgrades/"${VERSION}"/bin
  cd "${HOME}"/.sifnoded/cosmovisor/upgrades/"${VERSION}"/bin || exit 1
  wget -O sifnoded.zip https://github.com/Sifchain/sifnode/releases/download/${PREFIX}-${VERSION}/sifnoded-${PREFIX}-${VERSION}-linux-amd64.zip
  unzip sifnoded.zip

  # Check current version.
  if [ ! -d "${HOME}"/.sifnoded/cosmovisor/upgrades/"${CURRENT_VERSION}" ]; then
    mkdir -p "${HOME}"/.sifnoded/cosmovisor/upgrades/"${CURRENT_VERSION}"/bin
    cd "${HOME}"/.sifnoded/cosmovisor/upgrades/"${CURRENT_VERSION}"/bin || exit 1

    wget -O sifnoded.zip https://github.com/Sifchain/sifnode/releases/download/${PREFIX}-"${CURRENT_VERSION}"/sifnoded-${PREFIX}-"${CURRENT_VERSION}"-linux-amd64.zip
    unzip sifnoded.zip
  fi

  wget -O /usr/local/bin/migrate.sh https://raw.githubusercontent.com/Sifchain/networks/master/scripts/migrate.sh
  chmod +x /usr/local/bin/migrate.sh
  /usr/local/bin/migrate.sh -b "${INITIAL_HEIGHT}" -c "${CHAINNET}" -s "${COSMOS_SDK_VERSION}" -t "${GENESIS_TIME}" -v "${VERSION}" -w "${CURRENT_VERSION}" -z "${DATA_MIGRATE_VERSION}"
}

#
# Run the node under cosmovisor.
#
run() {
  if [ -f "${HOME}"/.sifnoded/.timestamp ] && [ ! -f "${HOME}"/.sifnoded/.upgraded ]; then
    _TIMESTAMP=$(cat "${HOME}"/.sifnoded/.timestamp)
    NOW=$(date +%s)
    if [ "${NOW}" -gt "${_TIMESTAMP}" ]; then
      nc -l 26657
    fi
  fi

  ADDITIONAL_ARGS=""
  if [ -f "${HOME}"/.sifnoded/.upgraded ]; then
    ADDITIONAL_ARGS="--x-crisis-skip-assert-invariants"
  elif [ -n "${TIMESTAMP}" ]; then
    echo "${TIMESTAMP}" > "${HOME}"/.sifnoded/.timestamp

    ADDITIONAL_ARGS="--halt-time ${TIMESTAMP}"
  fi

  cosmovisor start --rpc.laddr tcp://0.0.0.0:26657 --minimum-gas-prices "${GAS_PRICE}" "${ADDITIONAL_ARGS}"
}

if [ -z "${UPGRADE_NODE}" ] && [ "${UPGRADE_NODE}" == "true" ]; then
  upgrade
fi

setup
run
