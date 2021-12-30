#!/bin/sh
##!/usr/bin/env sh
# Sifchain.
#

. $(pwd)/scripts/globals.sh

#
# Usage.
#
usage() {
  cat <<- EOF
  Usage: $(basename "${0}") [OPTIONS]

  Options:
  -c      Chain ID.
  -m      Moniker.
  -p      Mnemonic (base64 encoded).
  -g      Gas prices.
  -b      Bind IP Address.
EOF
  exit 1
}

#
# Initialize.
#
init() {
  docker_installed
}

#
# Setup.
#
setup() {
  chain_id "${1}"
  moniker "${2}"
  mnemonic "${3}"
  gas_price "${4}"
  bind_ip_address "${5}"
}

#
# Run.
#
run() {
  #clear
  cat "$(pwd)"/scripts/.logo

  if [ -d "$(pwd)"/docker/sifchain/"${CHAIN_ID}"/.sifnoded ]; then
    docker-compose -f $(pwd)/docker/sifchain/"${CHAIN_ID}"/docker-compose.yml up
  else
    MONIKER="${MONIKER}" \
    MNEMONIC="$(echo "${MNEMONIC}" | base64 -d)" \
    GAS_PRICE="${GAS_PRICE}" \
    BIND_IP_ADDRESS="${BIND_IP_ADDRESS}" \
    docker-compose -f $(pwd)/docker/sifchain/"${CHAIN_ID}"/docker-compose.yml up
  fi
}

while getopts ":hc:m:p:g:b:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
      ;;
    m)
      m=${OPTARG}
      ;;
    p)
      p=${OPTARG}
      ;;
    g)
      g=${OPTARG}
      ;;
    b)
      b=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -d "$(pwd)"/docker/sifchain/"${CHAIN_ID}"/.sifnoded ]; then
  if [ -z "${c}" ]; then
    usage
  fi
else
  if [ -z "${c}" ] ||
      [ -z "${m}" ] ||
      [ -z "${p}" ] ||
      [ -z "${g}" ] ||
      [ -z "${b}" ]; then
    usage
  fi
fi

init
setup "${c}" "${m}" "${p}" "${g}" "${b}"
run "${0}"
