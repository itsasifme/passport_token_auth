# Gotchas We Actually Hit

Real problems hit setting up [ArgoCD + EKS](README.md) for this app, in the order they
surfaced — kept here instead of inline so the main walkthrough stays short.

> [!WARNING]
> **`main`/`staging`/`dev` branches can drift out of sync with each other.** `build.yml`
> used to always commit its image-tag bump to a fixed branch per environment, regardless
> of which branch you built from. It's since been changed to commit back to whichever
> branch triggered the run (`github.ref_name`) — branch and environment are independent
> choices now. Still, always check a target branch actually has the manifest fixes you
> expect before pointing an `Application`'s `targetRevision` at it.

> [!WARNING]
> **EKS Auto Mode's `gp2` StorageClass looks fine but silently can't provision anything.**
> `kubectl get storageclass` shows a `gp2` class using `kubernetes.io/aws-ebs`
> (CSI-migrated to `ebs.csi.aws.com`) — but Auto Mode nodes carry a taint that the
> *standard* EBS CSI driver's node DaemonSet doesn't tolerate (`ebs-csi-node` shows
> `DESIRED: 0` even with nodes present). **Don't install the "Amazon EBS CSI Driver" EKS
> add-on** — it can't work on Auto Mode nodes. Instead, Auto Mode already ships its own
> working driver under a different name, confirmed via a node's `CSINode` object:
> `ebs.csi.eks.amazonaws.com`. There's no default StorageClass for it though, so
> [`k8s/overlays/dev/storageclass.yaml`](../overlays/dev/storageclass.yaml) creates
> `auto-ebs-sc` referencing it directly, and both PVCs are patched to use it.

> [!WARNING]
> **`storageClassName` is immutable once a PVC exists** — even if it's stuck `Pending`
> and never bound. If you change which StorageClass a PVC should use, ArgoCD's patch
> will fail (`spec is immutable after creation`). Delete the stuck PVC (and any pod
> referencing it) so it gets recreated fresh with the new spec.

> [!NOTE]
> **kustomize version mismatch between local and CI.** `build.yml` pins
> `kustomize-version: '5.0.0'`; a locally-installed `kubectl` may bundle something newer
> (v5.8.1 here) with looser parsing. A multi-document patch file matched by resource name
> with no `target:` worked locally but failed in CI ("unable to parse SM or JSON patch").
> Stick to one resource per patch file for portability — verify locally against the exact
> CI-pinned version if in doubt, not just whatever's installed.

> [!WARNING]
> **Fresh EBS-backed PVCs mount as `root:root`.** Works fine on `kind` (its default
> local-path storage happens to be permissive), but breaks on any real cloud volume — the
> app container (running as uid 1412) can't write its own log files. Fixed via
> `securityContext.fsGroup: 1412` at the pod level in
> [`k8s/base/app-deployment.yaml`](../base/app-deployment.yaml), which makes Kubernetes
> set the mounted volume's group ownership to match on every mount.

> [!NOTE]
> **An intermediate directory ownership gap in the Dockerfile** (`storage/logs` itself was
> left `root`-owned even though its `supervisor` subdirectory was correctly chowned) broke
> a custom Laravel log channel that creates dated subdirectories (`cli_app/2026/07/...`) at
> runtime. `mkdir -p` creates *all* intermediate directories as whatever user runs it
> (root, pre-`USER` switch) — chowning only the leaf directory isn't enough; chown the
> whole tree.
