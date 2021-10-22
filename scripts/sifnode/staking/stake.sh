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
  -c      Commission max change rate.
  -d      Commission max rate.
  -e      Commission rate.
  -i      Chain ID.
  -m      Moniker.
  -a      Amount.
  -g      Gas.
  -p      Gas Prices.
  -k      Public Key.
  -r      Node RPC Address to broadcast to.
  -b      Keyring backend [test|file|os].
EOF
  exit 1
}

#
# Setup.
#
setup() {
  COMMISSION_MAX_CHANGE_RATE="${1}"
  COMMISSION_MAX_RATE="${2}"
  COMMISSION_RATE="${3}"
  CHAIN_ID="${4}"
  MONIKER="${5}"
  AMOUNT="${6}"
  GAS="${7}"
  GAS_PRICES="${8}"
  PUBLIC_KEY="${9}"
  NODE="${10}"
  KEYRING_BACKEND="${11}"
}

#
# Run.
#
run() {
  sifnoded tx staking create-validator \
  --commission-max-change-rate "${COMMISSION_MAX_CHANGE_RATE}" \
  --commission-max-rate "${COMMISSION_MAX_RATE}" \
  --commission-rate "${COMMISSION_RATE}" \
  --amount "${AMOUNT}" \
  --pubkey "${PUBLIC_KEY}" \
  --chain-id "${CHAIN_ID}" \
  --min-self-delegation "1" \
  --gas "${GAS}" \
  --gas-prices "${GAS_PRICES}" \
  --moniker "${MONIKER}" \
  --from "${MONIKER}" \
  --node "${NODE}" \
  --keyring-backend "${KEYRING_BACKEND}"
}

while getopts ":hc:d:e:i:m:a:g:p:k:r:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
      ;;
    d)
      d=${OPTARG}
      ;;
    e)
      e=${OPTARG}
      ;;
    i)
      i=${OPTARG}
      ;;
    m)
      m=${OPTARG}
      ;;
    a)
      a=${OPTARG}
      ;;
    g)
      g=${OPTARG}
      ;;
    p)
      p=${OPTARG}
      ;;
    k)
      k=${OPTARG}
      ;;
    r)
      r=${OPTARG}
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
    [ -z "${d}" ] ||
    [ -z "${e}" ] ||
    [ -z "${i}" ] ||
    [ -z "${m}" ] ||
    [ -z "${a}" ] ||
    [ -z "${g}" ] ||
    [ -z "${p}" ] ||
    [ -z "${k}" ] ||
    [ -z "${r}" ] ||
    [ -z "${b}" ]; then
  usage
fi

setup "${c}" "${d}" "${e}" "${i}" "${m}" "${a}" "${g}" "${p}" "${k}" "${r}" "${b}"
run "${0}"
