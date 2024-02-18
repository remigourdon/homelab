# Homelab

My homelab in its current iteration is built around a Kubernetes cluster, codename `clarke` after English cryptanalist [Joan Clarke](https://en.wikipedia.org/wiki/Joan_Clarke), who worked alongside [Alan Turing](https://en.wikipedia.org/wiki/Alan_Turing) on the Enigma project during WWII.

Some of the nodes of this cluster run on a [Turing Pi](https://turingpi.com/), which ties the names of these two historical figures in the fabric of my lab.

## Storage

[Democratic CSI](https://github.com/democratic-csi/democratic-csi) is used to provide storage to the Kubernetes cluster via my TrueNAS (formerly FreeNAS) installation.

At the moment I am using NFS only with the `freenas-api-nfs` CSI driver.

To make it work I first created the following on TrueNAS:

+ `NAS/k8s`
+ `NAS/k8s/nfs`
+ `NAS/k8s/nfs/vols`
+ `NAS/k8s/nfs/snaps`

I then created an API key for `CSI`.

Add the `democratic-csi` Helm repo:

```sh
helm repo add democratic-csi https://democratic-csi.github.io/charts/
helm repo update
```

The [Snapshot Controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html) is used to enable snapshot support.

```sh
helm upgrade --install --namespace kube-system --create-namespace snapshot-controller democratic-csi/snapshot-controller
kubectl -n kube-system logs -f -l app=snapshot-controller
```

The instructions below are based on the great write-up at `https://github.com/fenio/k8s-truenas`.

```sh
helm upgrade --install --create-namespace --values infrastructure/democratic-csi/nfs.yaml --namespace democratic-csi nfs democratic-csi/democratic-csi
kubectl label --overwrite namespace democratic-csi pod-security.kubernetes.io/enforce=privileged
```

Test PVC and snapshot:

```sh
kubectl apply --filename infrastructure/democratic-csi/pvc-nfs.yaml
kubectl get pvc
kubectl apply --filename infrastructure/democratic-csi/snapshot.yaml
kubectl describe volumesnapshots.snapshot.storage.k8s.io
kubectl delete --filename infrastructure/democratic-csi/pvc-nfs.yaml
kubectl get pvc
kubectl apply --filename infrastructure/democratic-csi/snapshot-restore.yaml
kubectl get pvc
```