#!/usr/bin/env sh
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
  -c      Cluster name.
EOF
  exit 1
}

#
# Setup.
#
setup() {
  cluster_name "${1}"
}

#
# Run.
#
run() {
  cd "${HOME}"/.terraform/"${CLUSTER_NAME}" || exit 1
  terraform apply -auto-approve
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
run "${0}"
