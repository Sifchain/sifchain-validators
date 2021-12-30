#!/bin/sh
##!/usr/bin/env sh
#
# Sifchain.
#

. $(pwd)/scripts/globals.sh

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
  jq_installed
}

#
# Setup
#
setup() {
  chain_id "${1}"
}

#
# Node status.
#
sifnode_status() {
  container="$(docker container ps | grep "${CHAIN_ID}" | awk '{ print $1 }')"
  if [ -z "${container}" ]; then
    clear
    printf "\nNo container found. Exiting.\n"
    exit 0
  fi

  STATUS=$(docker exec -it "${container}" sh -c "curl http://localhost:26657/status")
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

  sifnode_summary
}

while getopts ":hc:r:s:p:" opt; do
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
