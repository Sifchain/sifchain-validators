# Kubernetes

## AWS

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
