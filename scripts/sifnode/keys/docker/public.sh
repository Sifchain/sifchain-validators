#!/bin/sh
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

docker exec -it "$(docker container ps | grep "${c}" | awk '{ print $1 }')" /bin/sh -c 'sifnoded tendermint show-validator'
