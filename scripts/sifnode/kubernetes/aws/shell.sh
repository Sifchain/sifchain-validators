#!/usr/bin/env sh
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
# Sifnode shell.
#
sifnode_shell() {
  docker run -it \
  -e NAMESPACE=sifnode \
  -v "${AWS_MOUNT}" \
  -v "${KUBE_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -s -C /opt/deploy sifnode-kubernetes-shell"
}

#
# Run
#
run() {
  clear
  cat "$(pwd)"/scripts/.logo

  aws_configured "$(pwd)"

  if [ "${AWS_CONFIGURED}" ]; then
    # Set mounts.
    mount_aws "$(pwd)"
    mount_terraform "$(pwd)"
    mount_kube "$(pwd)"
    mount_deploy "$(pwd)"

    kubeconfig

    # Shell
    sifnode_shell
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
