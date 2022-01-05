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
  -e      Environment.
  -f      File.
EOF
  exit 1
}

#
# Setup.
#
setup() {
  environment "${1}"
  file "${2}"
}

#
# Run.
#
run() {
  contents=$(yq -r ".${ENVIRONMENT}" "${FILE}")
  echo "${contents}" | jq -r 'keys[] as $k | "\($k)=\(.[$k])"' | awk '{ print "echo "$1" >> \$GITHUB_ENV" }' | sh
}

while getopts ":he:f:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    e)
      e=${OPTARG}
      ;;
    f)
      f=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${e}" ] ||
    [ -z "${f}" ]; then
  usage
fi

setup "${e}" "${f}"
run
