#!/usr/bin/env sh
#
# Sifchain.
#

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
# Setup.
#
setup() {
  CHAIN_ID="${1}"
  MONIKER="${2}"
  MNEMONIC="${3}"
  GAS_PRICE="${4}"
  BIND_IP_ADDRESS="${5}"
}

#
# Run.
#
run() {
  MONIKER="${MONIKER}" \
  MNEMONIC="$(echo "${MNEMONIC}" | base64 -d)" \
  GAS_PRICE="${GAS_PRICE}" \
  BIND_IP_ADDRESS="${BIND_IP_ADDRESS}" \
  docker-compose -f $(pwd)/docker/sifchain/"${CHAIN_ID}"/docker-compose.yml up
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

if [ -z "${c}" ] ||
    [ -z "${m}" ] ||
    [ -z "${p}" ] ||
    [ -z "${g}" ] ||
    [ -z "${b}" ]; then
  usage
fi

setup "${c}" "${m}" "${p}" "${g}" "${b}"
run "${0}"
