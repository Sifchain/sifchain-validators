#!/bin/sh
#
# Sifchain.
#

. $(pwd)/scripts/globals.sh

PROVIDER=aws

#
# Usage.
#
usage() {
  cat <<- EOF
  Usage: $(basename "${0}") [OPTIONS]

  Options:
  -h      This help output.
  -c      Cluster.
  -r      Region.
  -s      Role.
  -p      Profile.
EOF
  exit 1
}

#
# Initialize.
#
init() {
  docker_installed
  jq_installed

  cat "$(pwd)"/scripts/.logo

  docker pull sifchain/wizard:latest 2>/dev/null &
  echo "Please wait..."
  clear
}

#
# Setup
#
setup() {
  cluster_name "${1}"
  aws_region "${2}"
  aws_role "${3}"
  aws_profile "${4}"
  AWS_PROFILE=${AWS_PROFILE:-sifchain}
}

#
# Generate kubeconfig.
#
kubeconfig() {
  docker run -it \
  -e CLUSTER_NAME="${CLUSTER_NAME}" \
  -e AWS_REGION="${AWS_REGION}" \
  -e AWS_PROFILE="${AWS_PROFILE}" \
  -v "${AWS_MOUNT}" \
  -v "${KUBE_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -s -C /opt/deploy provider-aws-kubeconfig"
}

#
# Node status.
#
sifnode_status() {
  STATUS=$(docker run -it \
  -e NAMESPACE=sifnode \
  -v "${AWS_MOUNT}" \
  -v "${KUBE_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -s -C /opt/deploy sifnode-kubernetes-status")
}

#
# Sifnode ID
#
sifnode_id() {
  SIFNODE_ID=$(echo "${STATUS}" | jq .result.node_info.id | xargs)
}

#
# Sifnode listen address.
#
sifnode_listen_address() {
  SIFNODE_LISTEN_ADDRESS=$(echo "${STATUS}" | jq .result.node_info.listen_addr | xargs)
}

#
# Sifnode Chain ID.
#
sifnode_chain_id() {
  SIFNODE_CHAIN_ID=$(echo "${STATUS}" | jq .result.node_info.network | xargs)
}

#
# Sifnode latest block hash.
#
sifnode_latest_block_hash() {
  SIFNODE_LATEST_BLOCK_HASH=$(echo "${STATUS}" | jq .result.sync_info.latest_block_hash | xargs)
}

#
# Sifnode latest app hash.
#
sifnode_latest_app_hash() {
  SIFNODE_LATEST_APP_HASH=$(echo "${STATUS}" | jq .result.sync_info.latest_app_hash | xargs)
}

#
# Sifnode latest block height.
#
sifnode_latest_block_height() {
  SIFNODE_LATEST_BLOCK_HEIGHT=$(echo "${STATUS}" | jq .result.sync_info.latest_block_height | xargs)
}

#
# Sifnode latest block time.
#
sifnode_latest_block_time() {
  SIFNODE_LATEST_BLOCK_TIME=$(echo "${STATUS}" | jq .result.sync_info.latest_block_time | xargs)
}

#
# Sifnode earliest block hash.
#
sifnode_earliest_block_hash() {
  SIFNODE_EARLIEST_BLOCK_HASH=$(echo "${STATUS}" | jq .result.sync_info.earliest_block_hash | xargs)
}

#
# Sifnode earliest app hash.
#
sifnode_earliest_app_hash() {
  SIFNODE_EARLIEST_APP_HASH=$(echo "${STATUS}" | jq .result.sync_info.earliest_app_hash | xargs)
}

#
# Sifnode earliest block height.
#
sifnode_earliest_block_height() {
  SIFNODE_EARLIEST_BLOCK_HEIGHT=$(echo "${STATUS}" | jq .result.sync_info.earliest_block_height | xargs)
}

#
# Sifnode earliest block time.
#
sifnode_earliest_block_time() {
  SIFNODE_EARLIEST_BLOCK_TIME=$(echo "${STATUS}" | jq .result.sync_info.earliest_block_time | xargs)
}

#
# Sifnode in sync?
#
sifnode_in_sync() {
  catching_up=$(echo "${STATUS}" | jq .result.sync_info.catching_up)
  if [ "${catching_up}" ]; then
    SIFNODE_IN_SYNC=false
  else
    SIFNODE_IN_SYNC=true
  fi
}

#
# Sifnode summary
#
sifnode_summary() {
  clear
  cat "$(pwd)"/scripts/.logo

  cat <<- EOF

Sifnode Summary
===============

Node
----
Node ID:                ${SIFNODE_ID}
Listen Address:         ${SIFNODE_LISTEN_ADDRESS}
Chain ID:               ${SIFNODE_CHAIN_ID}

Sync Info
---------
Latest Block Hash:      ${SIFNODE_LATEST_BLOCK_HASH}
Latest App Hash:        ${SIFNODE_LATEST_APP_HASH}
Latest Block Height:    ${SIFNODE_LATEST_BLOCK_HEIGHT}
Latest Block Time:      ${SIFNODE_LATEST_BLOCK_TIME}
Earliest Block Hash:    ${SIFNODE_EARLIEST_BLOCK_HASH}
Earliest App Hash:      ${SIFNODE_EARLIEST_APP_HASH}
Earliest Block Height:  ${SIFNODE_EARLIEST_BLOCK_HEIGHT}
Earliest Block Time:    ${SIFNODE_EARLIEST_BLOCK_TIME}
Synchronised?           ${SIFNODE_IN_SYNC}

EOF
}

#
# Run
#
run() {
  clear
  aws_configured $(pwd)

  if [ "${AWS_CONFIGURED}" ]; then
    # Set mounts.
    mount_aws $(pwd)
    mount_terraform $(pwd)
    mount_kube $(pwd)
    mount_deploy $(pwd)

    kubeconfig

    # Raw status
    sifnode_status

    # Processed status
    sifnode_id
    sifnode_listen_address
    sifnode_chain_id
    sifnode_latest_block_hash
    sifnode_latest_app_hash
    sifnode_latest_block_height
    sifnode_latest_block_time
    sifnode_earliest_block_hash
    sifnode_earliest_app_hash
    sifnode_earliest_block_height
    sifnode_earliest_block_time
    sifnode_in_sync

    sifnode_summary "${1}"
  else
    clear
    printf "\nAWS has not been configured. Exiting.\n"
    exit 0
  fi
}

while getopts ":hc:r:s:p:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
      ;;
    r)
      r=${OPTARG}
      ;;
    s)
      s=${OPTARG}
      ;;
    p)
      p=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${c}" ] ||
    [ -z "${r}" ]; then
  usage
fi

init "${0}"
setup "${c}" "${r}" "${s}" "${p}"
run "${0}"
