#!/usr/bin/env sh
#
# Sifchain.
#

BASEDIR=/app/sifnode/smart-contracts

#
# Install.
#
install() {
  npm install
}

#
# Get owner.
#
get_owner() {
  OWNER_ADDRESS=$(jq -r '.private_keys | keys_unsorted | .[0]' "${HOME}"/.ganache/keys/ganache.json)
}

#
# Get private key.
#
get_eth_private_key() {
  OWNER_PRIVATE_KEY=$(jq -r ".private_keys[\"${OWNER}\"]" "${HOME}"/.ganache/keys/ganache.json)
}

#
# Get ebrelayer address.
#
get_validator_address() {
  VALIDATOR_ADDRESS=$(jq -r '.private_keys | keys_unsorted | .[9]' "${HOME}"/.ganache/keys/ganache.json)
}

#
# Run.
#
run() {
  cd "${BASEDIR}" || exit 1
  install
  get_owner
  get_eth_private_key
  get_validator_address

  OWNER="${OWNER_ADDRESS}" \
  PAUSER="${OWNER_ADDRESS}" \
  OPERATOR="${OWNER_ADDRESS}" \
  ETHEREUM_PRIVATE_KEY="${OWNER_PRIVATE_KEY}" \
  CONSENSUS_THRESHOLD=100 \
  INITIAL_VALIDATOR_POWERS=100 \
  INITIAL_VALIDATOR_ADDRESSES="${VALIDATOR_ADDRESS}" npx truffle migrate --network develop
}

if [ ! -f "${HOME}"/.ganache/keys/ganache.json ]; then
  echo "Is ganache even running?"
  exit 1
fi

run
