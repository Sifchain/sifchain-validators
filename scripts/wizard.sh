#!/usr/bin/env sh
#
# Sifchain.
#

. $(pwd)/scripts/globals.sh

#
# Initialize.
#
init() {
  docker_installed

  docker pull sifchain/wizard:latest 2>/dev/null &
  pid=$!
  spinner $pid "Please wait..."
  clear
}

#
# Run.
#
run() {
  clear
  cat "$(pwd)"/scripts/.logo

  mount_aws "$(pwd)"
  mount_terraform "$(pwd)"
  mount_kube "$(pwd)"
  mount_deploy "$(pwd)"

  docker run -it \
  -v "${AWS_MOUNT}" \
  -v "${KUBE_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh
}

init
run
