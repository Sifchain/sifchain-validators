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
  -a      Access Key ID.
  -s      Secret Access Key.
  -r      Region.
  -o      Role.
  -p      Profile.
EOF
  exit 1
}

#
# Setup.
#
setup() {
  aws_access_key_id "${1}"
  aws_secret_access_key "${2}"
  aws_region "${3}"
  aws_role "${4}"
  aws_profile "${5}"
}

#
# Run.
#
run() {
  if [ ! -d "${HOME}"/.aws ]; then
    mkdir -p "${HOME}"/.aws
  fi

  cat << EOF >> "${HOME}"/.aws/credentials
[sifchain]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

  cat << EOF >> "${HOME}"/.aws/config
[profile ${AWS_PROFILE}]
role_arn = ${AWS_ROLE}
source_profile = sifchain
region = ${AWS_REGION}
EOF
}

while getopts ":ha:s:r:o:p:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    a)
      a=${OPTARG}
      ;;
    s)
      s=${OPTARG}
      ;;
    r)
      r=${OPTARG}
      ;;
    o)
      o=${OPTARG}
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

if [ -z "${a}" ] ||
    [ -z "${s}" ] ||
    [ -z "${r}" ] ||
    [ -z "${o}" ] ||
    [ -z "${p}" ]; then
  usage
fi

setup "${a}" "${s}" "${r}" "${o}" "${p}"
run
