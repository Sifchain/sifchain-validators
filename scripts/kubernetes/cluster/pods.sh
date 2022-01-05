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
  -n      namespace.
EOF
  exit 1
}

#
# Initialize.
#
init() {
  kubectl_installed
}

#
# Setup.
#
setup() {
  namespace "${1}"
}

#
# Run.
#
run() {
  kubectl get pods -n "${NAMESPACE}"
}

while getopts ":hn:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    n)
      n=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${n}" ]; then
  usage
fi

init
setup "${n}"
run
