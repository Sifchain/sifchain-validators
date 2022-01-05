# Kubernetes

## AWS

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
