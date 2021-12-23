#!/usr/bin/env sh
#
# Sifchain.
#

. $(pwd) ../scripts/globals.sh

#
# Usage.
#
usage() {
  cat <<- EOF
  Usage: $0 [OPTIONS]

  Options:
  -c      Chain ID
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
}

#
# Run.
#
run() {
  clear
  cat "$(pwd)"/scripts/.logo

  docker exec -it $(docker container ps | grep "${CHAIN_ID}" | awk '{ print $1 }') sh
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

init
setup "${c}"
run
