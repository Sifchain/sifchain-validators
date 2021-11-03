#
# Sifchain.
#

#
# Chain ID.
#
chain_id() {
  CHAIN_ID="${1}"
}

#
# Cluster name.
#
cluster_name() {
  CLUSTER_NAME="${1}"
}

#
# Provider.
#
provider() {
  PROVIDER="${1}"
}

#
# Namespace.
#
namespace() {
  NAMESPACE="${1}"
}

#
# Region.
#
region() {
  REGION="${1}"
}

#
# Instance type.
#
instance_type() {
  INSTANCE_TYPE="${1}"
}

#
# Profile.
#
profile() {
  PROFILE="${1}"
}

#
# AWS Access Key ID.
#
aws_access_key_id() {
  AWS_ACCESS_KEY_ID="${1}"
}

#
# AWS Secret Access Key.
#
aws_secret_access_key() {
  AWS_SECRET_ACCESS_KEY="${1}"
}

#
# AWS Region.
#
aws_region() {
  AWS_REGION="${1}"
}

#
# AWS Role.
#
aws_role() {
  AWS_ROLE="${1}"
}

#
# AWS Profile.
#
aws_profile() {
  AWS_PROFILE="${1}"
}

#
# Environment.
#
environment() {
  ENVIRONMENT="${1}"
}

#
# File.
#
file() {
  FILE="${1}"
}

#
# Moniker.
#
moniker() {
  MONIKER="${1}"
}

#
# Mnemonic.
#
mnemonic() {
  MNEMONIC="${1}"
}

#
# Gas price.
#
gas_price() {
  GAS_PRICE="${1}"
}

#
# Bind IP Address.
#
bind_ip_address() {
  BIND_IP_ADDRESS="${1}"
}

#
# Keyring backend.
#
keyring_backend() {
  KEYRING_BACKEND="${1}"
}

#
# Docker image.
#
docker_image() {
  DOCKER_IMAGE="${1}"
}

#
# Docker image tag.
#
docker_image_tag() {
  DOCKER_IMAGE_TAG="${1}"
}

#
# Peer address.
#
peer_address() {
  PEER_ADDRESS="${1}"
}

#
# Genesis URL.
#
genesis_url() {
  GENESIS_URL="${1}"
}

#
# Snapshot URL.
#
snapshot_url() {
  SNAPSHOT_URL="${1}"
}

#
# POD.
#
pod() {
  POD="${1}"
}

#
# ETH Websocket address.
#
eth_websocket_address() {
  ETH_WEBSOCKET_ADDRESS="${1}"
}

#
# ETH Bridge Registry address.
#
eth_bridge_registry_address() {
  ETH_BRIDGE_REGISTRY_ADDRESS="${1}"
}

#
# ETH Symbol mapping.
#
eth_symbol_mapping() {
  ETH_SYMBOL_MAPPING="${1}"
}

#
# Tail.
#
tail_count() {
  TAIL_COUNT="${1}"
}

#
# Docker installed?
#
docker_installed() {
  installed=$(command -v docker)
  if [ "${installed}" = 1 ]; then
    echo "docker does not appear to be installed. Please see: https://docs.docker.com/get-docker/"
    exit 1
  fi
}

#
# kubectl installed?
#
kubectl_installed() {
  installed=$(command -v kubectl)
  if [ "${installed}" = 1 ]; then
    echo "kubectl does not appear to be installed. Please see: https://kubernetes.io/docs/tasks/tools/#kubectl"
    exit 1
  fi
}

#
# terraform installed?
#
terraform_installed() {
  installed=$(command -v terraform)
  if [ "${installed}" = 1 ]; then
    echo "terraform does not appear to be installed. Please see: http://terraform.io"
    exit 1
  fi
}

#
# AWS CLI installed?
#
awscli_installed() {
  installed=$(command -v aws)
  if [ "${installed}" = 1 ]; then
    echo "aws cli does not appear to be installed. Please see: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html"
    exit 1
  fi
}

#
# jq installed?
#
jq_installed() {
  installed=$(command -v jq)
  if [ "${installed}" = 1 ]; then
    echo "jq does not appear to be installed. Please see: https://stedolan.github.io/jq/"
    exit 1
  fi
}

#
# AWS Mount.
#
mount_aws() {
  AWS_MOUNT="${1}"/.${PROVIDER}:/root/.${PROVIDER}
}

#
# Terraform Mount.
#
mount_terraform() {
  TERRAFORM_MOUNT="${1}"/.terraform:/root/.terraform
}

#
# Kube Mount.
#
mount_kube() {
  KUBE_MOUNT="${1}"/.kube:/root/.kube
}

#
# Deploy Mount.
#
mount_deploy() {
  DEPLOY_MOUNT="${1}":/opt/deploy
}

#
# AWS Configured?
#
aws_configured() {
  if [ -f "${1}"/.aws/config ] && [ -f "${1}"/.aws/credentials ]; then
    AWS_CONFIGURED=true
  else
    AWS_CONFIGURED=false
  fi
}
