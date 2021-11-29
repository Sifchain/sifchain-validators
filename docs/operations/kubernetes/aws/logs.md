# Kubernetes

## AWS

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
