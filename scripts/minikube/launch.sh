#!/usr/bin/env sh
#
# Sifchain TempNet Launcher.
#

#
# Usage.
#
usage() {
  cat <<- EOF
  Usage: $0 [OPTIONS]

  Options:
  -h      This help output.
  -c      Chain ID for sifnoded.
  -d      Chain ID for gaiad.
  -m      Moniker for sifnoded.
  -o      Moniker for gaiad.
  -i      Docker image tag for sifnoded.
  -j      Docker image tag for gaiad.
  -n      Namespace to deploy into.

EOF
  exit 1
}

#
# Setup.
#
setup() {
  SIFNODE_CHAIN_ID=${1}
  GAIA_CHAIN_ID=${2}
  SIFNODE_MONIKER=${3}
  GAIA_MONIKER=${4}
  SIFNODE_IMAGE_TAG=${5}
  GAIA_IMAGE_TAG=${6}
  NAMESPACE=${7}
}

#
# Sifnode Admin Mnemonic.
#
admin_mnemonic() {
  ADMIN_MNEMONIC=$(sifgen key generate)
}

#
# Sifnode Admin Address.
#
admin_address() {
  ADMIN_ADDRESS=$(sifgen key recover "${ADMIN_MNEMONIC}" | head -1 | awk -F\\: '{ print $2 }' | xargs)
}

#
# Deploy Sifnode.
#
deploy_sifnode() {
  printf "Deploying sifnoded...\n"
  helm upgrade sifnode $(pwd)/../../helm/standalone/sifnode --install -n "${NAMESPACE}" \
  --create-namespace \
  --set sifnode.env.chainnet="${SIFNODE_CHAIN_ID}" \
  --set sifnode.env.moniker="${SIFNODE_MONIKER}" \
  --set sifnode.args.mnemonic="${ADMIN_MNEMONIC}" \
  --set sifnode.args.enableAPI=true \
  --set sifnode.args.enableGrpc=true \
  --set sifnode.args.enableRpc=true \
  --set sifnode.args.enableExternalAPI=true \
  --set sifnode.args.enableExternalGrpc=true \
  --set sifnode.args.enableExternalRpc=true \
  --set sifnode.args.adminCLPAddresses="${ADMIN_ADDRESS}" \
  --set sifnode.args.adminOracleAddress="${ADMIN_ADDRESS}" \
  --set sifnode.args.standalone=true \
  --set image.repository=sifchain/sifnoded \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  --set provider="local" \
  --set image.tag="${SIFNODE_IMAGE_TAG}"
}

#resources:
#  requests:
#    cpu: 2
#    memory: 8Gi
#  limits:
#    memory: 16Gi

#
# Deploy Gaia
#
deploy_gaia() {
  printf "Deploying gaiad...\n"
  helm upgrade gaia $(pwd)/../../helm/standalone/gaia --install -n "${NAMESPACE}" \
  --create-namespace \
  --set gaia.env.chainnet="${GAIA_CHAIN_ID}" \
  --set gaia.env.moniker="${GAIA_MONIKER}" \
  --set gaia.args.mnemonic="${ADMIN_MNEMONIC}" \
  --set image.repository=sifchain/gaia \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  --set provider="local" \
  --set image.tag="${GAIA_IMAGE_TAG}"
}

#
# Cosmos nodes ready?
#
cosmos_ready() {
  COSMOS_READY=$(kubectl -n "${NAMESPACE}" get pods -o go-template='{{range $index, $element := .items}}{{range .status.containerStatuses}}{{if .ready}}{{$element.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}' | wc -l | xargs)
}

#
# Deploy TS Relayer
#
deploy_ts_relayer() {
  printf "Deploying ts-relayer...\n"
  cosmos_ready
  until [ "${COSMOS_READY}" -eq 2 ]; do
    echo "Waiting for the cosmos nodes to become available..."
    sleep 30
    cosmos_ready
  done

  helm upgrade gaia-ts-relayer $(pwd)/../../helm/standalone/ibc-ts-relayer --install -n "${NAMESPACE}" \
  --create-namespace \
  --set tsRelayer.args.mnemonic="$(echo -n \"${ADMIN_MNEMONIC}\" | base64)" \
  --set tsRelayer.env.chainnet0="${SIFNODE_CHAIN_ID}" \
  --set tsRelayer.env.chainnet1="${GAIA_CHAIN_ID}" \
  --set tsRelayer.env.prefix0=sif \
  --set tsRelayer.env.prefix1=cosmos \
  --set tsRelayer.env.gas_price0="0.5rowan" \
  --set tsRelayer.env.gas_price1="0.1stake" \
  --set tsRelayer.env.rpc0=http://sifnode-rpc."${NAMESPACE}":26657 \
  --set tsRelayer.env.rpc1=http://gaia."${NAMESPACE}":26657 \
  --set image.repository=sifchain/ts-relayer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  --set image.tag=latest
}

#
# Deploy mongoDb
#
deploy_mongodb() {
  printf "Deploying mongodb...\n"

  MONGODB_PASSWORD=$(pwgen 32 1)
  MONGODB_ROOT_PASSWORD=$(pwgen 32 1)

  helm upgrade mongodb --install -n "${NAMESPACE}" \
  -f $(pwd)/../../helm/standalone/mongodb/values.yaml \
  --set auth.rootPassword="${MONGODB_ROOT_PASSWORD}" \
  --set auth.username="mongodb" \
  --set auth.password="${MONGODB_PASSWORD}" \
  --set auth.database="block_explorer" \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  bitnami/mongodb --create-namespace
}

#
# Deploy Block Explorer
#
deploy_block_explorer() {
  printf "Deploying block-explorer...\n"
  helm upgrade block-explorer $(pwd)/../../helm/standalone/block-explorer \
  --install -n "${NAMESPACE}" --create-namespace \
  --set blockExplorer.env.chainnet="${SIFNODE_CHAIN_ID}" \
  --set blockExplorer.env.rootURL=http://localhost:3000 \
  --set blockExplorer.env.remote.rpcURL=http://sifnode-rpc."${NAMESPACE}":26657 \
  --set blockExplorer.env.remote.apiURL=http://sifnode-api."${NAMESPACE}":1317 \
  --set blockExplorer.args.mongoPassword="${MONGODB_PASSWORD}" \
  --set blockExplorer.args.mongoHostname=mongodb."${NAMESPACE}" \
  --set image.repository=sifchain/block-explorer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  --set image.tag=mainnet-0.3.0
}

#
# Deploy Ganache
#
deploy_ganache() {
  printf "Deploying ganache...\n"
  helm upgrade ganache $(pwd)/../../helm/standalone/ganache \
  --install -n "${NAMESPACE}" --create-namespace \
  --set ganache.args.mnemonic="${ADMIN_MNEMONIC}" \
  --set ganache.args.networkId=5777 \
  --set image.repository=sifchain/ganache \
  --set resources.requests.cpu=200m \
  --set resources.requests.memory=200Mi \
  --set resources.limits.memory=400Mi \
  --set image.tag=latest
  sleep 30
}

#
# Ganache pod.
#
get_ganache_pod() {
  GANACHE_POD=$(kubectl get pods -n "${NAMESPACE}" -l 'app.kubernetes.io/instance=ganache' -o json | jq '.items[0].metadata.name' | xargs)
}

#
# Ganache ready?
#
ganache_ready() {
  GANACHE_READY=$(kubectl -n "${NAMESPACE}" get pods -o go-template='{{range $index, $element := .items}}{{range .status.containerStatuses}}{{if .ready}}{{$element.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}' -l 'app.kubernetes.io/instance=ganache' | xargs | wc -l)
}

#
# Deploy smart contracts.
#
deploy_smart_contracts() {
  printf "Deploying the smart contracts...\n"
  ganache_ready
  until [ "${GANACHE_READY}" -eq 1 ]; do
    echo "Waiting for ganache to become available..."
    sleep 15
    ganache_ready
  done
  kubectl exec --stdin --tty "${GANACHE_POD}" -n "${NAMESPACE}" -- /bin/sh -c /usr/bin/deploy.sh
}

#
# Copy Ganache files.
#
copy_ganache_files() {
  printf "Downloading files from ganache...\n"
  copy_ganache_keys
  copy_ganache_bridge_registry
  copy_ganache_bridge_token
  copy_ganache_bridge_bank
}

#
# Copy Ganache keys.
#
copy_ganache_keys() {
  kubectl cp "${GANACHE_POD}":/root/.ganache/keys/ganache.json "${TMPDIR}"/ganache.json -n "${NAMESPACE}"
}

#
# Copy Ganache Bridge Registry.
#
copy_ganache_bridge_registry() {
  kubectl cp "${GANACHE_POD}":/app/sifnode/smart-contracts/build/contracts/BridgeRegistry.json "${TMPDIR}"/BridgeRegistry.json -n "${NAMESPACE}"
}

#
# Copy Ganache Bridge Token.
#
copy_ganache_bridge_token() {
  kubectl cp "${GANACHE_POD}":/app/sifnode/smart-contracts/build/contracts/BridgeToken.json "${TMPDIR}"/BridgeToken.json -n "${NAMESPACE}"
}

#
# Copy Ganache Bridge Token.
#
copy_ganache_bridge_bank() {
  kubectl cp "${GANACHE_POD}":/app/sifnode/smart-contracts/build/contracts/BridgeBank.json "${TMPDIR}"/BridgeBank.json -n "${NAMESPACE}"
}

#
# Deploy ebrelayer.
#
deploy_ebrelayer() {
  get_ganache_bridge_registry_address
  get_ganache_validator_address
  get_ganache_validator_private_key

  printf "Deploying ebrelayer...\n"
  helm upgrade ebrelayer $(pwd)/../../helm/standalone/ebrelayer \
  --install -n "${NAMESPACE}" --create-namespace \
  --set ebrelayer.args.nodeHost="tcp://sifnode-rpc.${NAMESPACE}:26657" \
  --set ebrelayer.args.ethWebsocketAddress="ws://ganache.${NAMESPACE}:7545" \
  --set ebrelayer.args.ethBridgeRegistryAddress="${GANACHE_BRIDGE_REGISTRY_ADDRESS}" \
  --set ebrelayer.args.mnemonic="${ADMIN_MNEMONIC}" \
  --set ebrelayer.args.symbolMapping=eyJpYmMvRkVFREZBQ0VGRUVERkFDRUZFRURGQUNFRkVFREZBQ0VGRUVERkFDRUZFRURGQUNFRkVFREZBQ0VGRUVERkFDRSI6ICJGYWNlIiwgInJvd2FuIjogImVyb3dhbiJ9 \
  --set ebrelayer.env.chainnet="${SIFNODE_CHAIN_ID}" \
  --set ebrelayer.env.moniker="${SIFNODE_MONIKER}" \
  --set ebrelayer.env.ethPrivateKey="${GANACHE_VALIDATOR_PRIVATE_KEY}" \
  --set image.repository=sifchain/ebrelayer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=100Mi \
  --set resources.limits.memory=200Mi \
  --set image.tag="${SIFNODE_IMAGE_TAG}"
}

#
# Sifnode.
#
get_sifnode() {
  get_sifnode_p2p_hostname
  get_sifnode_rpc_hostname
  get_sifnoded_grpc_hostname
  get_sifnoded_api_hostname
}

#
# Sifnode P2P hostname.
#
get_sifnode_p2p_hostname() {
  SIFNODE_P2P_HOSTNAME=$(kubectl get svc sifnode -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Sifnode RPC hostname.
#
get_sifnode_rpc_hostname() {
  SIFNODE_RPC_HOSTNAME=$(kubectl get svc sifnode-rpc -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Sifnode gRPC hostname.
#
get_sifnoded_grpc_hostname() {
  SIFNODE_GRPC_HOSTNAME=$(kubectl get svc sifnode-grpc -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Sifnode API hostname.
#
get_sifnoded_api_hostname() {
  SIFNODE_API_HOSTNAME=$(kubectl get svc sifnode-api -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Gaia hostname.
#
get_gaiad_hostname() {
  GAIAD_HOSTNAME=$(kubectl get svc gaia -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# MongoDB hostname.
#
get_mongodb_hostname() {
  MONGODB_HOSTNAME=$(kubectl get svc mongodb -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Block Explorer URL.
#
get_block_explorer_url() {
  BLOCK_EXPLORER_URL=$(kubectl get svc block-explorer -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Ganache.
#
get_ganache() {
  get_ganache_hostname
  get_ganache_validator_address
  get_ganache_validator_private_key
  get_ganache_bridge_registry_address
  get_ganache_bridge_token_address
  get_ganache_bridge_bank_address
}

#
# Ganache hostname.
#
get_ganache_hostname() {
  GANACHE_HOSTNAME=$(kubectl get svc ganache -n "${NAMESPACE}" -o json | jq ".status.loadBalancer.ingress[0].hostname" | xargs)
}

#
# Ganache validator address.
#
get_ganache_validator_address() {
  GANACHE_VALIDATOR_ADDRESS=$(jq -r '.private_keys | keys_unsorted | .[9]' "${TMPDIR}"/ganache.json)
}

#
# Ganache validator private key.
#
get_ganache_validator_private_key() {
  GANACHE_VALIDATOR_PRIVATE_KEY=$(jq -r ".private_keys[\"${GANACHE_VALIDATOR_ADDRESS}\"]" "${TMPDIR}"/ganache.json)
}

#
# Ganache bridge registry address.
#
get_ganache_bridge_registry_address() {
  GANACHE_BRIDGE_REGISTRY_ADDRESS=$(jq -r '.networks["5777"].address' "${TMPDIR}"/BridgeRegistry.json)
}

#
# Ganache bridge token address.
#
get_ganache_bridge_token_address() {
  GANACHE_BRIDGE_TOKEN_ADDRESS=$(jq -r '.networks["5777"].address' "${TMPDIR}"/BridgeToken.json)
}

#
# Ganache bridge bank address.
#
get_ganache_bridge_bank_address() {
  GANACHE_BRIDGE_BANK_ADDRESS=$(jq -r '.networks["5777"].address' "${TMPDIR}"/BridgeBank.json)
}

#
# Summary.
#
summary() {
  get_sifnode
  get_gaiad_hostname
  get_mongodb_hostname
  get_block_explorer_url
  get_ganache

  clear

  cat $(pwd)/../.logo

  cat <<- EOF

  Overview
  ========
  +------------------------------------------------+
  | NB: THE SAME MNEMONIC IS USED FOR ALL SERVICES |
  +------------------------------------------------+
  Mnemonic:                                           ${ADMIN_MNEMONIC}

  Kubernetes
  ==========
  Namespace:                                          ${NAMESPACE}

  Sifnode
  =======
  P2P:                                                ${SIFNODE_P2P_HOSTNAME}:26656
  RPC:                                                ${SIFNODE_RPC_HOSTNAME}:26657
  gRPC:                                               ${SIFNODE_GRPC_HOSTNAME}:9090
  API:                                                ${SIFNODE_API_HOSTNAME}:1317

  Gaia (CosmosHub)
  ================
  P2P/RPC:                                            ${GAIAD_HOSTNAME}

  MongoDB
  =======
  Username:                                           mongodb
  Password:                                           ${MONGODB_PASSWORD}
  Root Password:                                      ${MONGODB_ROOT_PASSWORD}
  Hostname:                                           ${MONGODB_HOSTNAME}:27017
  Database:                                           block_explorer

  Block Explorer
  ==============
  URL:                                                http://${BLOCK_EXPLORER_URL}

  Ganache
  =======
  Hostname:                                           ${GANACHE_HOSTNAME}:7545
  Validator Address:                                  ${GANACHE_VALIDATOR_ADDRESS}
  Validator Private Key:                              ${GANACHE_VALIDATOR_PRIVATE_KEY}
  Bridge Registry Address:                            ${GANACHE_BRIDGE_REGISTRY_ADDRESS}
  Bridge Token Address:                               ${GANACHE_BRIDGE_TOKEN_ADDRESS}
  Bridge Bank Address:                                ${GANACHE_BRIDGE_BANK_ADDRESS}
EOF
}

#
# Run.
#
run() {
  admin_mnemonic
  admin_address
  deploy_sifnode
  deploy_gaia
  deploy_ts_relayer
  deploy_mongodb
  deploy_block_explorer
  deploy_ganache
  get_ganache_pod
  deploy_smart_contracts
  copy_ganache_files
  deploy_ebrelayer

  summary
  exit 0
}

while getopts ":hc:d:m:o:i:j:n:" opt; do
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
    m)
      m=${OPTARG}
      ;;
    o)
      o=${OPTARG}
      ;;
    i)
      i=${OPTARG}
      ;;
    j)
      j=${OPTARG}
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

if [ -z "${c}" ] ||
    [ -z "${d}" ] ||
    [ -z "${m}" ] ||
    [ -z "${o}" ] ||
    [ -z "${i}" ] ||
    [ -z "${j}" ] ||
    [ -z "${n}" ]; then
  usage
fi

setup "${c}" "${d}" "${m}" "${o}" "${i}" "${j}" "${n}"
run
