# Storage

## Upgrade

Earlier versions of the `sifnode` stack on Kubernetes had a PVC size of 500GB. As the chain size has grown substantially, this is no longer appropriate.

To ensure that your `sifnode` pod remains operational, you will need to expand the storage allocated.

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
