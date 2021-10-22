SHELL := env CLUSTER_NAME=$(CLUSTER_NAME) CHAIN_ID=$(CHAIN_ID) NAMESPACE=$(NAMESPACE) DOCKER_IMAGE=$(DOCKER_IMAGE) DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) MONIKER=$(MONIKER) MNEMONIC=$(MNEMONIC) PEER_ADDRESS=$(PEER_ADDRESS) GENESIS_URL=$(GENESIS_URL) API_ACCESS=$(API_ACCESS) ENABLE_API_ACCESS=$(ENABLE_API_ACCESS) GRPC_ACCESS=$(GRPC_ACCESS) ENABLE_GRPC_ACCESS=$(ENABLE_GRPC_ACCESS) RPC_ACCESS=$(RPC_ACCESS) ENABLE_RPC_ACCESS=$(ENABLE_RPC_ACCESS) ENABLE_EXTERNAL_API_ACCESS=$(ENABLE_EXTERNAL_API_ACCESS) ENABLE_EXTERNAL_GRPC_ACCESS=$(ENABLE_EXTERNAL_GRPC_ACCESS) ENABLE_EXTERNAL_RPC_ACCESS=$(ENABLE_EXTERNAL_RPC_ACCESS) AWS_REGION=$(AWS_REGION) AWS_ROLE=$(AWS_ROLE) AWS_PROFILE=$(AWS_PROFILE) POD=$(POD) $(SHELL)

KEYRING_BACKEND?=test
CHAIN_ID?=sifchain-testnet-1
NAMESPACE?="sifnode"
GAS_PRICES?=0.5rowan
BIND_IP_ADDRESS?=127.0.0.1
COMMISSION_MAX_CHANGE_RATE?=0.1
COMMISSION_MAX_RATE?=0.1
COMMISSION_RATE?=0.1
GAS?=300000
CLUSTER_NAME?=""
PROVIDER?=aws
REGION?="us-east-1"
AWS_REGION?="us-east-1"
INSTANCE_TYPE?="m5.2xlarge"
AWS_ROLE?=""
PROFILE?="sifchain"
AWS_PROFILE?=""
API_ACCESS?=false
GRPC_ACCESS?=false
RPC_ACCESS?=false
EXTERNAL_API_ACCESS?=false
EXTERNAL_GRPC_ACCESS?=false
EXTERNAL_RPC_ACCESS?=false
ENABLE_EXTERNAL_API_ACCESS?=false
ENABLE_EXTERNAL_GRPC_ACCESS?=false
ENABLE_EXTERNAL_RPC_ACCESS?=false
SNAPSHOT_URL?=""
POD?=""

build-image:
	docker build -t sifchain/$(SERVICE):$(IMAGE_TAG) -f ./docker/$(SERVICE)/$(IMAGE_TAG)/Dockerfile .

bundler:
	@gem install bundler
	@bundler install

lint:
	@bundle exec rubocop rake/lib rake/spec

tests:
	@cd rake && bundle exec rspec

sifnode-keys-generate-mnemonic:
	@./scripts/sifnode/keys/mnemonic.sh

sifnode-keys-import:
	@./scripts/sifnode/keys/import.sh -m $(MONIKER) -b $(KEYRING_BACKEND)

sifnode-keys-show:
	@./scripts/sifnode/keys/show.sh -m $(MONIKER) -b $(KEYRING_BACKEND)

sifnode-kubernetes-wizard:
	@./scripts/sifnode/kubernetes/wizard.sh -c $(CHAIN_ID) -p "$(PROVIDER)"

sifnode-standalone-boot:
	@./scripts/sifnode/standalone/boot.sh -c $(CHAIN_ID) -m $(MONIKER) -p "$(MNEMONIC)" -g $(GAS_PRICES) -b $(BIND_IP_ADDRESS)

sifnode-standalone-wizard:
	@./scripts/sifnode/standalone/wizard.sh -c $(CHAIN_ID)

sifnode-standalone-shell:
	@./scripts/sifnode/standalone/shell.sh -c $(CHAIN_ID)

sifnode-staking-stake:
	@./scripts/sifnode/staking/stake.sh -c $(COMMISSION_MAX_CHANGE_RATE) -d $(COMMISSION_MAX_RATE) -e $(COMMISSION_RATE) -a $(AMOUNT) -g $(GAS) -p $(GAS_PRICES) -k $(PUBKEY) -r $(NODE) -b $(KEYRING_BACKEND)

kubernetes-cluster-scaffold:
	@./scripts/kubernetes/cluster/scaffold.sh -c $(CLUSTER_NAME) -d $(PROVIDER) -r $(REGION) -i $(INSTANCE_TYPE) -p $(PROFILE)

kubernetes-cluster-deploy:
	@./scripts/kubernetes/cluster/deploy.sh -c $(CLUSTER_NAME)

provider-aws-configure:
	@./scripts/provider/aws/configure.sh -a $(AWS_ACCESS_KEY_ID) -s $(AWS_SECRET_ACCESS_KEY) -r $(AWS_REGION) -o $(AWS_ROLE) -p $(PROFILE)

provider-aws-kubeconfig:
	@./scripts/provider/aws/kubeconfig.sh -c $(CLUSTER_NAME) -r $(AWS_REGION) -s $(AWS_ROLE) -p $(AWS_PROFILE)

provider-github-var-map:
	@./scripts/provider/github/var_map.sh -e $(ENVIRONMENT) -f $(FILE)

sifnode-kubernetes-deploy-peer:
	@./scripts/sifnode/kubernetes/deploy/peer.sh -c $(CHAIN_ID) -n $(NAMESPACE) -d $(DOCKER_IMAGE) -t $(DOCKER_IMAGE_TAG) -m $(MONIKER) -q "$(MNEMONIC)" -p $(PEER_ADDRESS) -u $(GENESIS_URL) -a $(ENABLE_API_ACCESS) -g $(ENABLE_GRPC_ACCESS) -r $(ENABLE_RPC_ACCESS) -b $(ENABLE_EXTERNAL_API_ACCESS) -i $(ENABLE_EXTERNAL_GRPC_ACCESS) -s $(ENABLE_EXTERNAL_RPC_ACCESS)

sifnode-kubernetes-deploy-peer-snapshot:
	@./scripts/sifnode/kubernetes/deploy/peer/snapshot.sh -c $(CHAIN_ID) -n $(NAMESPACE) -d $(DOCKER_IMAGE) -t $(DOCKER_IMAGE_TAG) -m $(MONIKER) -q "$(MNEMONIC)" -p $(PEER_ADDRESS) -u $(GENESIS_URL) -a $(ENABLE_API_ACCESS) -g $(ENABLE_GRPC_ACCESS) -r $(ENABLE_RPC_ACCESS) -b $(ENABLE_EXTERNAL_API_ACCES) -i $(ENABLE_EXTERNAL_GRPC_ACCESS) -s $(ENABLE_EXTERNAL_RPC_ACCESS) -S $(SNAPSHOT_URL)

sifnode-kubernetes-status:
	@./scripts/sifnode/kubernetes/status.sh -n $(NAMESPACE)

sifnode-kubernetes-aws-status:
	@./scripts/sifnode/kubernetes/aws/status.sh -c $(CLUSTER_NAME) -r $(AWS_REGION) -p $(AWS_PROFILE)

sifnode-kubernetes-shell:
	@./scripts/sifnode/kubernetes/shell.sh -n $(NAMESPACE)

sifnode-kubernetes-aws-shell:
	@./scripts/sifnode/kubernetes/aws/shell.sh -c $(CLUSTER_NAME) -r $(AWS_REGION) -p $(AWS_PROFILE)

testnet-launch:
	@./scripts/testnet/launch.sh -c $(CHAIN_ID) -m "$(VALIDATOR_MNEMONICS)" -a "$(ADMIN_MNEMONICS)" -n $(NAMESPACE) -i $(DOCKER_IMAGE_TAG) -e $(ETH_WEBSOCKET_ADDRESS) -b $(ETH_BRIDGE_REGISTRY_ADDRESS) -s $(ETH_SYMBOL_MAPPING) -p "$(ETH_PRIVATE_KEYS)"
