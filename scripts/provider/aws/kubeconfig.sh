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
  awscli_installed
}

#
# Setup.
#
setup() {
  cluster_name "${1}"
  aws_region "${2}"
  aws_role "${3}"
  aws_profile "${4}"
}

#
# Run.
#
run() {
  if [ -n "${AWS_PROFILE}" ] && [ -n "${AWS_ROLE}" ]; then
    aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --role-arn "${AWS_ROLE}" --profile "${AWS_PROFILE}"
  elif [ -n "${AWS_PROFILE}" ] && [ -z "${AWS_ROLE}" ]; then
    aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --profile "${AWS_PROFILE}"
  elif [ -z "${AWS_PROFILE}" ] && [ -n "${AWS_ROLE}" ]; then
    aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --role-arn "${AWS_ROLE}"
  else
    aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"
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

init
setup "${c}" "${r}" "${s}" "${p}"
run
