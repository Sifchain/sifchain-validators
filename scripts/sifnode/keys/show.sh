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
  Usage: $(basename "${0}") [OPTIONS]

  Options:
  -h      This help output.
  -m      Moniker.
  -b      Keyring backend [file|test|os].
EOF
  exit 1
}

#
# Setup.
#
setup() {
  moniker "${1}"
  keyring_backend "${2}"
}

while getopts ":hm:b:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    m)
      m=${OPTARG}
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

if [ -z "${m}" ] || [ -z "${b}" ]; then
  usage
fi

setup "${m}" "${b}"
sifnoded keys show "${MONIKER}" --keyring-backend "${KEYRING_BACKEND}"
