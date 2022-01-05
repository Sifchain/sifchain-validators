#!/bin/sh
#
# Sifchain.
#

. $(pwd)/scripts/globals.sh

#
# Usage.
#
usage() {
  cat <<- EOF
  Usage: $0 [OPTIONS]

  Options:
  -h      This help output.
  -c      Chain ID.

EOF
  exit 1
}

#
# Initialize.
#
init() {
  docker_installed

  cat "$(pwd)"/scripts/.logo
  docker pull sifchain/sifnoded:"${CHAIN_ID}"
  echo "Installing dependencies. Please wait..."
}

#
# Setup
#
setup() {
  chain_id "${1}"
}

#
# Generate mnemonic.
#
sifnode_mnemonic() {
  MNEMONIC=$(docker run -it sifchain/sifnoded:"${CHAIN_ID}" /bin/sh -c "sifgen key generate")
}

#
# Moniker.
#
sifnode_moniker() {
  read -p "Enter the moniker for your node: " MONIKER
}

#
# Gas prices.
#
sifnode_gas_prices() {
  read -p "Enter the default gas price for your node [0.5rowan]: " GAS_PRICES
  GAS_PRICES=${GAS_PRICES:-0.5rowan}
}

#
# Bind IP Address.
#
sifnode_bind_ip_address() {
  read -p "Enter the IP address that your node should advertise to the rest of the network [127.0.0.1]: " BIND_IP_ADDRESS
  BIND_IP_ADDRESS=${BIND_IP_ADDRESS:-127.0.0.1}
}

#
# Launch.
#
launch() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

To launch your validator for the first time, please run:

CHAIN_ID="${CHAIN_ID}" \\
MONIKER="${MONIKER}" \\
MNEMONIC="$(echo "${MNEMONIC}" | base64)" \\
GAS_PRICES="${GAS_PRICES}" \\
BIND_IP_ADDRESS="${BIND_IP_ADDRESS}" \\
make sifnode-standalone-boot

EOF
}

#
# Sifnode summary.
#
sifnode_summary() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Summary
-------
Chain ID: ${CHAIN_ID}
Moniker: ${MONIKER}
Mnemonic: ${MNEMONIC}
Gas Price: ${GAS_PRICES}
IP Address: ${BIND_IP_ADDRESS}

PLEASE REMEMBER TO STORE YOUR MNEMONIC SOMEWHERE SECURE!

EOF
}

#
# New node.
#
new() {
  clear
  if [ -d "$(pwd)"/docker/sifchain/"${CHAIN_ID}"/.sifnoded ]; then
    rm -rf "$(pwd)"/docker/sifchain/"${CHAIN_ID}"/.sifnoded
  fi

  cat "$(pwd)"/scripts/.logo

  sifnode_mnemonic
  sifnode_moniker
  sifnode_gas_prices
  sifnode_bind_ip_address
  sifnode_summary

  read -p "Are these details correct? (y/n): " OUTPUT
  echo

  if [ "${OUTPUT}" = "y" ]; then
    echo "Launching...."
    launch
  else
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi
}

#
# Run.
#
run() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Sifchain
--------
Welcome to the Sifchain standalone wizard!

This will assist you in setting up a new (or launching an existing) standalone sifnode node, and connecting to the
network within a couple of minutes.

EOF
  printf "\n\n"
  read -p "Would you like to continue? (y/n): " -n 1 -r

  if [ "${REPLY}" = "n" ]; then
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi

  if [ -d "$(pwd)"/docker/sifchain/"${CHAIN_ID}"/.sifnoded ]; then
    printf "\n\n"
    read -p "Detected an existing configuration. Would you like to run that now? [If not, it'll be deleted] (y/n): " -n 1 -r

    if [ "${REPLY}" = "y" ]; then
      echo "Launching...."
      launch "${1}"
      exit 0
    else
      new "${1}"
    fi
  else
    new "${1}"
  fi
}

while getopts ":hc:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${c}" ]; then
  usage
fi

init "${0}"
setup "${c}"
sleep 2
run "${0}"
