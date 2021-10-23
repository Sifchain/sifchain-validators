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

  cat "$(pwd)"/scripts/.logo

  docker pull sifchain/wizard:latest 2>/dev/null &
  pid=$!
  spinner $pid "Installing dependencies. Please wait..."
  clear
}

#
# Run.
#
run() {
    clear
    cat "$(pwd)"/scripts/.logo

    cat <<- EOF

AWS Configure
-------------
If you've not already signed up for an AWS account, then please do so here:

https://portal.aws.amazon.com/billing/signup#/start

Once done, or if you have an existing account, you'll then need to setup a new IAM user or use your existing
IAM credentials. For more information please see:

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

EOF
  printf "\n\n"
  read -p "Would you like to continue? (y/n): " -n 1 -r

  if [ "${REPLY}" = "n" ]; then
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi

  clear
  cat "$(pwd)"/scripts/.logo
  docker run -it -v $(pwd)/.aws:/root/.aws sifchain/wizard:latest aws configure --profile sifchain

  clear
  printf "\n\n"
  exit 0
}

init
run
