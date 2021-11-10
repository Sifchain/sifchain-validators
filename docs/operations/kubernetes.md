# Kubernetes

## AWS

The commands below are a collection of common use cases, for managing a sifnode container running on EKS.

### Configure

To setup AWS for the first time or to update your AWS credentials, run:

```bash
make sifnode-kubernetes-aws-configure
```

Your credentials will be stored in a folder named `.aws`.

### Kubeconfig

To generate a kubernetes config file, run:

```bash
CLUSTER_NAME=<cluster_name> AWS_REGION=<region> make sifnode-kubernetes-aws-kubeconfig
```

where:

|Param|Description|
|-----|----------|
|`<cluster_name>`|The name of your cluster.|
|`<aws_region>`|The AWS region where your cluster was deployed to.|

e.g.:

```bash
CLUSTER_NAME=my-cluster AWS_REGION=us-west-2 make sifnode-kubernetes-aws-kubeconfig
```

The config will be stored in a folder named `.kube`.

### Terminal

To open up a new terminal session with your running node, run:

```bash
CLUSTER_NAME=<cluster_name> AWS_REGION=<region> make sifnode-kubernetes-aws-shell
```

where:

|Param|Description|
|-----|----------|
|`<cluster_name>`|The name of your cluster.|
|`<aws_region>`|The AWS region where your cluster was deployed to.|

e.g.:

```bash
CLUSTER_NAME=my-cluster AWS_REGION=us-west-2 make sifnode-kubernetes-aws-shell
```

### Logs

To tail the logs of your running node, run:

```bash
TAIL_COUNT=<count> CLUSTER_NAME=<cluster_name> AWS_REGION=<region> make sifnode-kubernetes-aws-logs
```

where:

|Param|Description|
|-----|----------|
|`<count>`|The number of previous log rows from which to start the tail from.|
|`<cluster_name>`|The name of your cluster.|
|`<aws_region>`|The AWS region where your cluster was deployed to.|

e.g.:

```bash
TAIL_COUNT=150 CLUSTER_NAME=my-cluster AWS_REGION=us-west-2 make sifnode-kubernetes-aws-logs
```

### Status

To obtain the status of your running node, run:

```bash
CLUSTER_NAME=<cluster_name> AWS_REGION=<region> make sifnode-kubernetes-aws-status
```

where:

|Param|Description|
|-----|----------|
|`<cluster_name>`|The name of your cluster.|
|`<aws_region>`|The AWS region where your cluster was deployed to.|

e.g.:

```bash
CLUSTER_NAME=my-cluster AWS_REGION=us-west-2 make sifnode-kubernetes-aws-status
```

### Wizard

The recent tooling updates also include a custom Sifchain docker image, named `wizard`. This image contains all the key components of managing a kubernetes cluster, including:

* [AWS CLI](https://aws.amazon.com/cli/)
* [Terraform](https://terraform.io)
* [helm](https://helm.sh/docs/intro/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

This was done to ensure that the dependencies required for running a Sifnode were kept to a bare minimum.

Prior to launching `wizard`, it's recommended that you follow the earlier steps above for configuring AWS and generating a kubernetes config file.

To launch `wizard`, run:

```bash
make wizard
```

This will then open a terminal session, from which you can use commands such as `kubectl` to manage your cluster as you see fit.

### Restore a Snapshot

There may come a time when you need to restore your node from a snapshot. This could be for a number of reasons, but the most common is a broken upgrade.

1. Launch the wizard as described above:

```bash
make wizard
```

2. Re-deploy your sifnode with a snapshot:

```bash
CHAIN_ID=<chain_id> \
NAMESPACE=sifnode \
DOCKER_IMAGE=sifchain/sifnoded \
DOCKER_IMAGE_TAG=<chain_id> \
MONIKER=<moniker> \
SNAPSHOT_URL=<snapshot_url> \
make sifnode-kubernetes-deploy-peer-snapshot
```

where:

|Param|Description|
|-----|----------|
|`<chain_id>`|The chain ID of the network your node is running on (snapshots are only currently provided for BetaNet - `sifchain-1`).|
|`<moniker>`|The moniker or name of your node as it appears on the network.|
|`<snapshot_url>`|The URL to the snapshot.|

e.g.:

```bash
CHAIN_ID=sifchain-1 \
NAMESPACE=sifnode \
DOCKER_IMAGE=sifchain/sifnoded \
DOCKER_IMAGE_TAG=sifchain-1 \
MONIKER=my-node \
SNAPSHOT_URL=https://url.to/the/snapshot \
make sifnode-kubernetes-deploy-peer-snapshot
```

Snapshots for BetaNet can be found [here](https://github.com/Sifchain/networks/blob/master/betanet/sifchain-1/snapshots.md).
