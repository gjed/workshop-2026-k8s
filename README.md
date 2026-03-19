# Workshop Kubernetes 2026

Kubernetes workshop environment hosted by ReeVo.

## Cluster

| Role | Address |
|------|---------|
| Master | `3.67.26.50` |
| Worker | `10.0.1.154` |

Kubernetes **v1.31.0**, 2 nodes.

## Quick start

```bash
# SSH into master
make ssh-master

# SSH into worker (via master jump host)
make ssh-worker

# List cluster nodes
make nodes
```

Requires the SSH private key (`marco.pernigo.key`) with `chmod 600` permissions in the repo root.

## Repo structure

```
apps/           # Application manifests (deployed by ArgoCD)
  nginx/        # nginx deployment (6 replicas, nginx:1.29)
argocd/         # ArgoCD Application definitions
Makefile        # SSH shortcuts
```

## ArgoCD

ArgoCD syncs from this repo (`main` branch). Each app under `apps/` has a corresponding ArgoCD Application in `argocd/`.

To deploy the ArgoCD application:

```bash
kubectl apply -f argocd/nginx.yaml
```
