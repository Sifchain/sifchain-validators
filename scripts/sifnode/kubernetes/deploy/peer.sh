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
  -c      Chain ID.
  -n      Namespace.
  -d      Docker Image.
  -t      Docker Image Tag.
  -m      Moniker.
  -q      Mnemonic.
  -p      Peer Address.
  -u      Genesis URL.
  -a      Enable API Access [true|false].
  -g      Enable gRPC Access [true|false].
  -r      Enable RPC Access [true|false].
  -b      Enable External API Access [true|false].
  -i      Enable External gRPC Access [true|false].
  -s      Enable External RPC Access [true|false].
  -S      Snapshot URL.
EOF
  exit 1
}

#
# Setup.
#
setup() {
  chain_id "${1}"
  namespace "${2}"
  docker_image "${3}"
  docker_image_tag "${4}"
  moniker "${5}"
  mnemonic "$(echo "${6}" | base64 -d)"
  peer_address "${7}"
  genesis_url "${8}"

  API_ACCESS="${9}"
  GRPC_ACCESS="${10}"
  RPC_ACCESS="${11}"
  EXTERNAL_API_ACCESS="${12}"
  EXTERNAL_GRPC_ACCESS="${13}"
  EXTERNAL_RPC_ACCESS="${14}"

  snapshot_url "${15}"
}

#
# Run.
#
run() {
  helm upgrade sifnode $(pwd)/helm/standalone/sifnode \
  --install -n "${NAMESPACE}" --create-namespace \
  --set sifnode.env.chainnet="${CHAIN_ID}" \
  --set sifnode.env.moniker="${MONIKER}" \
  --set sifnode.args.mnemonic="${MNEMONIC}" \
  --set sifnode.args.enableAPI="${API_ACCESS}" \
  --set sifnode.args.enableGrpc="${GRPC_ACCESS}" \
  --set sifnode.args.enableRpc="${RPC_ACCESS}" \
  --set sifnode.args.enableExternalAPI="${EXTERNAL_API_ACCESS}" \
  --set sifnode.args.enableExternalGrpc="${EXTERNAL_GRPC_ACCESS}" \
  --set sifnode.args.enableExternalRpc="${EXTERNAL_RPC_ACCESS}" \
  --set sifnode.args.peerAddress="${PEER_ADDRESS}" \
  --set sifnode.args.genesisURL="${GENESIS_URL}" \
  --set sifnode.args.snapshotURL="${SNAPSHOT_URL}" \
  --set image.tag="${DOCKER_IMAGE_TAG}" \
  --set image.repository="${DOCKER_IMAGE}"
}

while getopts ":hc:n:d:t:m:q:p:u:a:g:r:b:i:s:S:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
      ;;
    n)
      n=${OPTARG}
      ;;
    d)
      d=${OPTARG}
      ;;
    t)
      t=${OPTARG}
      ;;
    m)
      m=${OPTARG}
      ;;
    q)
      q=${OPTARG}
      ;;
    p)
      p=${OPTARG}
      ;;
    u)
      u=${OPTARG}
      ;;
    a)
      a=${OPTARG}
      ;;
    g)
      g=${OPTARG}
      ;;
    r)
      r=${OPTARG}
      ;;
    b)
      b=${OPTARG}
      ;;
    i)
      i=${OPTARG}
      ;;
    s)
      s=${OPTARG}
      ;;
    S)
      S=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${c}" ] ||
    [ -z "${n}" ] ||
    [ -z "${d}" ] ||
    [ -z "${t}" ] ||
    [ -z "${m}" ] ||
    [ -z "${q}" ] ||
    [ -z "${p}" ] ||
    [ -z "${u}" ] ||
    [ -z "${a}" ] ||
    [ -z "${g}" ] ||
    [ -z "${r}" ] ||
    [ -z "${b}" ] ||
    [ -z "${i}" ] ||
    [ -z "${s}" ]; then
  usage
fi

setup "${c}" "${n}" "${d}" "${t}" "${m}" "${q}" "${p}" "${u}" "${a}" "${g}" "${r}" "${b}" "${i}" "${s}" "${S}"
run "${0}"
