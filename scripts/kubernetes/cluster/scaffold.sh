#!/usr/bin/env sh
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
  -c      Cluster name.
  -d      Provider.
  -r      Region.
  -i      Instance type.
  -p      Profile.
EOF
  exit 1
}

#
# Initialize.
#
init() {
  terraform_installed
}

#
# Setup.
#
setup() {
  cluster_name "${1}"
  provider "${2}"
  region "${3}"
  instance_type "${4}"
  profile "${5}"
}

#
# Run.
#
run() {
  DIR="${HOME}"/.terraform/"${CLUSTER_NAME}"
  mkdir -p "${DIR}"
  cp "$(pwd)"/terraform/template/"${PROVIDER}"/cluster.tf.tpl "${DIR}"/main.tf

  sed -i s/{{cluster_name}}/"${CLUSTER_NAME}"/g "${DIR}"/main.tf
  sed -i s/{{region}}/"${REGION}"/g "${DIR}"/main.tf
  sed -i s/{{instance_type}}/"${INSTANCE_TYPE}"/g "${DIR}"/main.tf
  sed -i s/{{profile}}/"${PROFILE}"/g "${DIR}"/main.tf

  cd "${DIR}" || exit 1
  terraform init
}

while getopts ":hc:d:r:i:p:" opt; do
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
    r)
      r=${OPTARG}
      ;;
    i)
      i=${OPTARG}
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
    [ -z "${d}" ] ||
    [ -z "${r}" ] ||
    [ -z "${i}" ] ||
    [ -z "${p}" ]; then
  usage
fi

init
setup "${c}" "${d}" "${r}" "${i}" "${p}"
run "${0}"
