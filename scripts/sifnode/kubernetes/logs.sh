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
  -t      Tail count.
  -n      Namespace.
EOF
  exit 1
}

#
# Setup
#
setup() {
  tail_count "${1}"
  namespace "${2}"
}

#
# Sifnode pod
#
sifnode_pod() {
  POD=$(kubectl get pods -n sifnode -l 'app.kubernetes.io/instance=sifnode' -o json | jq '.items[0].metadata.name')
}

#
# Sifnode logs
#
sifnode_logs() {
  kubectl logs $(echo "${POD}" | xargs) -n "${NAMESPACE}" --tail "${TAIL_COUNT}" -f
}

#
# Run
#
run() {
  sifnode_pod
  sifnode_logs
}

while getopts ":hn:t:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    n)
      n=${OPTARG}
      ;;
    t)
      t=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${t}" ] ||
    [ -z "${n}" ]; then
  usage
fi

setup "${t}" "${n}"
run "${0}"
