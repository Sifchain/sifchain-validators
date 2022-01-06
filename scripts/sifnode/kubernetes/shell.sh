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
  -n      Namespace.
EOF
  exit 1
}

#
# Setup
#
setup() {
  namespace "${1}"
}

#
# Sifnode pod
#
sifnode_pod() {
  POD=$(kubectl get pods -n sifnode -l 'app.kubernetes.io/instance=sifnode' -o json | jq '.items[0].metadata.name')
}

#
# Sifnode shell
#
sifnode_shell() {
  kubectl exec --stdin --tty $(echo "${POD}" | xargs) -n "${NAMESPACE}" -c sifnode -- sh
}

#
# Run
#
run() {
  sifnode_pod
  sifnode_shell
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

setup "${n}"
run "${0}"
