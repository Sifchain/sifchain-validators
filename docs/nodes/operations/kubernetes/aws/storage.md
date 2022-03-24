# Storage

## Upgrade

Earlier versions of the `sifnode` stack on Kubernetes had a PVC size of 500GB. As the chain size has grown substantially, this is no longer appropriate.

To ensure that your `sifnode` pod remains operational, you will need to expand the storage allocated.

### Steps

1. Using `kubectl`, edit the default storage class:

```console
kubectl edit storageclass gp2
```

2. An editor will now open (typically `vi` or `vim`) and you can edit the storage class config. Please add the option `allowVolumeExpansion: true` to the top, directly above `apiVersion`, so it looks like so:

```yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
...
```

3. Save and exit. This now allows us to expand a volume inline, with no downtime.

4. Edit the PVC for sifnode:

```console
kubectl edit pvc sifnode -n sifnode
```

5. Scroll down until you find the `spec:` section. It should look something *like* this:

```yaml
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Gi
  storageClassName: gp2
  volumeMode: Filesystem
```

6. Change the value for the `storage` key to `2000Gi`, so it looks like:

```yaml
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2000Gi
  storageClassName: gp2
  volumeMode: Filesystem
```

7. Save and exit. Your volume will now resize and your node won't be at risk of running out of disk space anytime soon.

### Verify

You can verify that the volume has been expanded successfully several ways:

* Log into your AWS account, go to `EC2` -> `Volumes` and you should see the volume in question expanded to 2TB. Additionally, it'll also report a status of `Optimizing`.

* Check the PVC with `kubectl` by running:

```console
kubectl get pvc -n sifnode
```

and it will output something similar to this:

```console
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
sifnode   Bound    <volume_name>                              2000Gi     RWO            gp2            406d
```

* Open up a tty to the pod by running:

```console
kubectl exec --stdin --tty <pod_name> -n sifnode -- sh
```

where:

|Param|Description|
|-----|-----------|
|`<pod_name>`|The name of the pod running `sifnoded`.|

e.g.:

```console
kubectl exec --stdin --tty sifnode-dc7cb12345-c9546 -n sifnode -- sh
```

Once you have an active shell, you can run:

```console
df -h
```

and it should show the `/root` volume was expanded to 2TB.

