#!/usr/bin/env sh
#
# Sifchain.
#

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
# Chain ID.
#
chain_id() {
  CHAIN_ID="${1}"
}

#
# Run.
#
run() {
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

chain_id "${c}"
run
