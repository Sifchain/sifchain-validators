#!/bin/bash
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
  -h      This help output.
  -p      Provider.
  -c      Chain ID.

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
  echo "Installing dependencies. Please wait..."
  clear
}

#
# Setup
#
setup() {
  chain_id "${1}"
  provider "${2}"
}

#
# Setup AWS.
#
aws() {
  clear
  cat "$(pwd)"/scripts/.logo

  cat <<- EOF

AWS Credentials Setup
---------------------
In this step we'll configure your AWS credentials. If you've not already signed up for an AWS account,
then please do so here:

https://portal.aws.amazon.com/billing/signup#/start

Once done, or if you have an existing account, you'll then need to setup a new IAM user or use your existing
IAM credentials. For more information please see:

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

Please note: at present only AWS is supported by this wizard.

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
  docker run -it -v $(pwd)/."${PROVIDER}":/root/."${PROVIDER}" sifchain/wizard:latest aws configure --profile sifchain
}

#
# Provider summary
#
provider_summary() {
  clear
  cat "$(pwd)"/scripts/.logo

  case "${PROVIDER}" in
    aws)
      aws_access_key_id=$(grep aws_access_key_id $(pwd)/."${PROVIDER}"/credentials | awk '{ print $3 }' | cut -c 16- | awk '{ print "****************"$1 }')
      aws_secret_access_key=$(grep aws_secret_access_key $(pwd)/."${PROVIDER}"/credentials | awk '{ print $3 }' | cut -c 36- | awk '{ print "****************"$1 }')
      PROVIDER_REGION=$(grep region $(pwd)/."${PROVIDER}"/config | awk '{ print $3 }')

cat <<- EOF

AWS Summary
-----------
AWS Access Key ID: ${aws_access_key_id}
AWS Secret Access Key: ${aws_secret_access_key}
AWS Region: ${PROVIDER_REGION}
EOF
      printf "\n\n"
      read -p "Would you like to continue? (y/n): " -n 1 -r

      if [ "${REPLY}" = "n" ]; then
        clear
        printf "\nExiting. Goodbye.\n"
        exit 0
      else
        clear
      fi
      ;;
    *)
      ;;
  esac
}

#
# Terraform.
#
terraform() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Terraform Setup
---------------
In this step we'll configure terraform, scaffold your new EKS cluster and deploy it. Terraform is an infrastructure as
code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently.

For further details, please see:

https://www.terraform.io

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
}

#
# Cluster name.
#
terraform_cluster_name() {
  default=$(echo "${RANDOM}" | tr '0-9' '[:lower:]')
  read -p "Enter the name for your cluster: [sifchain-${default}]: " CLUSTER_NAME
  CLUSTER_NAME=${CLUSTER_NAME:-sifchian-${default}}
}

#
# Region
#
terraform_region() {
  case "${PROVIDER}" in
    aws)
      read -p "Please provide the region to deploy your cluster to. If you're not sure, please see https://docs.aws.amazon.com/general/latest/gr/rande.html [${PROVIDER_REGION}]: " REGION
      PROVIDER_REGION=${REGION:-${PROVIDER_REGION}}
      ;;
    *)
      ;;
  esac
}

#
# Instance type.
#
terraform_instance_type() {
  case "${PROVIDER}" in
    aws)
      read -p "Please provide the instance type to be used for the cluster. If you're not sure, please see https://aws.amazon.com/ec2/instance-types [m5.2xlarge]: " INSTANCE_TYPE
      INSTANCE_TYPE=${INSTANCE_TYPE:-m5.2xlarge}
      ;;
    *)
      ;;
  esac
}

#
# Terraform summary
#
terraform_summary() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Terraform Summary
-----------------
Cluster name: ${CLUSTER_NAME}
Region: ${PROVIDER_REGION}
Instance type: ${INSTANCE_TYPE}
EOF

  printf "\n\n"
  read -p "Would you like to continue? (y/n): " -n 1 -r

  if [ "${REPLY}" = "n" ]; then
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi
}

#
# Scaffold cluster.
#
terraform_scaffold_cluster() {
  printf "\n\n"

  docker run -it \
  -e CLUSTER_NAME="${CLUSTER_NAME}" \
  -e PROVIDER="${PROVIDER}" \
  -e REGION="${PROVIDER_REGION}" \
  -e INSTANCE_TYPE="${INSTANCE_TYPE}" \
  -v "${AWS_MOUNT}" \
  -v "${TERRAFORM_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -s -C /opt/deploy kubernetes-cluster-scaffold"
}

#
# Deploy cluster.
#
terraform_deploy_cluster() {
  printf "\n\n"

  docker run -it \
  -e CLUSTER_NAME="${CLUSTER_NAME}" \
  -v "${AWS_MOUNT}" \
  -v "${TERRAFORM_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -s -C /opt/deploy kubernetes-cluster-deploy"
}

#
# Sifnode.
#
sifnode() {
  clear
  cat "$(pwd)"/scripts/.logo

  cat <<- EOF

Sifnode Setup
-------------
In this step we'll configure and deploy a new sifnode instance.

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
}

#
# Generate mnemonic.
#
sifnode_mnemonic() {
  MNEMONIC=$(docker run -it sifchain/wizard:latest /bin/sh -c "sifgen key generate")
}

#
# Moniker.
#
sifnode_moniker() {
  read -p "Enter the moniker for your node: " MONIKER
}

#
# Gas prices.
#
sifnode_gas_prices() {
  read -p "Enter the default gas price for your node [0.5rowan]: " GAS_PRICES
  GAS_PRICES=${GAS_PRICES:-0.5rowan}
}

#
# Enable API?
#
sifnode_enable_api() {
  read -p "Enable public access to the rest API service? [false]: " ENABLE_API
  ENABLE_API=${ENABLE_API:-false}
}

#
# Enable RPC?
#
sifnode_enable_rpc() {
  read -p "Enable public access to the RPC service? [false]: " ENABLE_RPC
  ENABLE_RPC=${ENABLE_RPC:-false}
}

#
# Enable gRPC?
#
sifnode_enable_grpc() {
  read -p "Enable public access to the gRPC service? [false]: " ENABLE_GRPC
  ENABLE_GRPC=${ENABLE_GRPC:-false}
}

#
# Summary.
#
sifnode_summary() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Sifnode Summary
---------------
Chain ID: ${CHAIN_ID}
Moniker: ${MONIKER}
Mnemonic: ${MNEMONIC}
Gas price: ${GAS_PRICES}
Public API access: ${ENABLE_API}
Public RPC access: ${ENABLE_RPC}
Public gRPC access: ${ENABLE_GRPC}

PLEASE REMEMBER TO STORE YOUR MNEMONIC SOMEWHERE SECURE!

EOF
  printf "\n\n"
  read -p "Would you like to continue? (y/n): " -n 1 -r

  if [ "${REPLY}" = "n" ]; then
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi
}

#
# Generate kubeconfig.
#
kubeconfig() {
  case "${PROVIDER}" in
    aws)
      cmd="CLUSTER_NAME=${CLUSTER_NAME} AWS_REGION=${PROVIDER_REGION} AWS_PROFILE=sifchain make -C /opt/deploy provider-aws-kubeconfig"
      ;;
    *)
      ;;
  esac

  docker run -it -v "${AWS_MOUNT}" -v "${KUBE_MOUNT}" -v "${DEPLOY_MOUNT}" sifchain/wizard:latest sh -c "${cmd}"
}

#
# Genesis URL.
#
# @todo: Make this dynamic.
#
genesis_url() {
  case "${CHAIN_ID}" in
    sifchain-1)
      GENESIS_URL=https://rpc.sifchain.finance/genesis
      ;;
    sifchain-testnet-1)
      GENESIS_URL=https://rpc-testnet.sifchain.finance/genesis
      ;;
    *)
      ;;
  esac
}

#
# Persistent peers.
#
# @todo: Make this dynamic.
#
persistent_peers() {
  case "${CHAIN_ID}" in
    sifchain-1)
      PERSISTENT_PEERS=MGQ0OTgxYmRhZjRkNWQ3M2JhZDAwYWYzYjFmYTlkNjk5ZTRkM2JjMEA0NC4yMzUuMTA4LjQxOjI2NjU2LGJjYzJkMDdhMTRhOGEwYjNhYTIwMmU5YWMxMDZkZWMwYmVmOTFmZGFAMTMuNTUuMjQ3LjYwOjI2NjU2LDY2M2RlYzY1Yjc1NGFjZWVmNWZjY2NiODY0MDQ4MzA1MjA4ZTdlYjJAMzQuMjQ4LjExMC44ODoyNjY1NiwwMTIwZjBhNDhlN2U4MWNjOTg4MjllZjRmNWIzOTQ4MGYxMWVjZDVhQDUyLjc2LjE4NS4xNzoyNjY1Niw2NTM1NDk3ZjAxNTIyOTNkNzczMTA4Nzc0YTcwNWI4NmMyMjQ5YTljQDQ0LjIzOC4xMjEuNjU6MjY2NTYsZmRmNWNmZmMyYjIwYTIwZmFiOTU0ZDNiNjc4NWU5YzM4Mjc2MmQxNEAzNC4yNTUuMTMzLjI0ODoyNjY1Niw4YzI0MGY3MWY5ZTA2MDI3N2NlMThkYzA5ZDgyZDNiYmIwNWQxOTcyQDEzLjIxMS40My4xNzc6MjY2NTYsOWZiY2I2YmQ1YTdmMjBhNzE2NTY0MTU3YzRmNjI5NmQyZmFmNWY2NEAxOC4xMzguMjA4Ljk1OjI2NjU2Cg==
      ;;
    sifchain-testnet-1)
      PERSISTENT_PEERS=YzQxNDBjNTU0NzA2NjE5M2JkMjA3NjVhODA1MGU1NjQyZDJhMDJmZkA1NC44NS4zOS4xOTM6MjY2NTYsNzA0NWFmYjZkY2Y5ZjMwMWIyOWRmYjA4ZTA4OTM5YjNjM2ZhNzRhNkA1NC4yMTEuNDEuOTY6MjY2NTYsZmY2NDgxNDY4MzY4ZmNiMTRjNjU3ZTAwNzllNzc5MTU5OTcxMGJlN0A1NC4xNjIuMi4yNTU6MjY2NTYsM2ZiODRiZjBkMzFlN2VlOGM1MTJiMGU2ZjgyZmJiYTcwNTFmM2YxZkA1NC4xNTguMTIxLjE4NjoyNjY1Ng==
      ;;
    *)
      ;;
  esac
}

#
# Deploy sifnode.
#
sifnode_deploy() {
  if [ "${ENABLE_RPC}" != "true" ] && [ "${ENABLE_RPC}" != "false" ]; then
    ENABLE_RPC=false
  fi

  if [ "${ENABLE_GRPC}" != "true" ] && [ "${ENABLE_GRPC}" != "false" ]; then
    ENABLE_GRPC=false
  fi

  if [ "${ENABLE_API}" != "true" ] && [ "${ENABLE_API}" != "false" ]; then
    ENABLE_API=false
  fi

  genesis_url
  persistent_peers

  docker run -it \
  -e CHAIN_ID="${CHAIN_ID}" \
  -e NAMESPACE=sifnode \
  -e DOCKER_IMAGE="sifchain/sifnoded" \
  -e DOCKER_IMAGE_TAG="${CHAIN_ID}" \
  -e MONIKER="${MONIKER}" \
  -e MNEMONIC="$(echo "${MNEMONIC}" | base64)" \
  -e PEER_ADDRESS="${PERSISTENT_PEERS}" \
  -e GENESIS_URL=${GENESIS_URL} \
  -e ENABLE_API_ACCESS=true \
  -e ENABLE_GRPC_ACCESS=true \
  -e ENABLE_RPC_ACCESS=true \
  -e ENABLE_EXTERNAL_API_ACCESS=${ENABLE_API} \
  -e ENABLE_EXTERNAL_GRPC_ACCESS=${ENABLE_GRPC} \
  -e ENABLE_EXTERNAL_RPC_ACCESS=${ENABLE_RPC} \
  -v "${AWS_MOUNT}" \
  -v "${KUBE_MOUNT}" \
  -v "${DEPLOY_MOUNT}" \
  sifchain/wizard:latest sh -c "make -C /opt/deploy sifnode-kubernetes-deploy-peer"
}

#
# Run
#
run() {
  clear
  cat "$(pwd)"/scripts/.logo
  cat <<- EOF

Sifchain
--------
Welcome to the Sifchain kubernetes wizard!

This will assist you to launch a new Kubernetes cluster, deploy a new sifnode to the cluster and join the network.

This process will take roughly 45 minutes to complete.

EOF
  printf "\n\n"
  read -p "Would you like to continue? (y/n): " -n 1 -r

  if [ "${REPLY}" = "n" ]; then
    clear
    printf "\nExiting. Goodbye.\n"
    exit 0
  fi

  # Provider
  case "${PROVIDER}" in
    aws)
      aws "${1}"
      ;;
    *)
      aws "${1}"
      ;;
  esac

  provider_summary "${1}"

  # Terraform.
  terraform "${1}"
  terraform_cluster_name
  terraform_region
  terraform_instance_type
  terraform_summary "${1}"

  # Set mounts.
  mount_aws "$(pwd)"
  mount_terraform "$(pwd)"
  mount_kube "$(pwd)"
  mount_deploy "$(pwd)"

  # Execute.
  terraform_scaffold_cluster
  terraform_deploy_cluster

  # Sifnode
  sifnode
  sifnode_mnemonic
  sifnode_moniker
  sifnode_gas_prices
  sifnode_enable_rpc
  sifnode_enable_grpc
  sifnode_enable_api
  sifnode_summary

  clear
  cat "$(pwd)"/scripts/.logo

  kubeconfig
  sifnode_deploy

  # Finish
  clear
  cat "$(pwd)"/scripts/.logo
  case "${PROVIDER}" in
    aws)
      cat <<- EOF

Sifchain
--------
The setup has completed!

It may take up to 5 minutes before your node is active on the network. You can view the status of your node simply by running:

CLUSTER_NAME=<cluster_name> AWS_REGION=<aws_region> make sifnode-kubernetes-aws-status

Please reach out to us on discord with any questions you might have:

https://discord.gg/YEBD4VrQ

EOF
      ;;
    *)
      ;;
  esac
  printf "\n\n"
}

while getopts ":hc:p:" opt; do
  case "${opt}" in
    h)
      usage
      ;;
    c)
      c=${OPTARG}
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
  [ -z "${p}" ]; then
  usage
fi

init "${0}"
setup "${c}" "${p}"
run "${0}"
