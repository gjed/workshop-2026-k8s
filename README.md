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
  argocd.yaml   # ArgoCD self-managing (Helm chart)
  nginx.yaml    # nginx app
Makefile        # SSH shortcuts
```

## Bootstrap

From the master node, run the following to install ArgoCD and let it manage itself + all apps:

```bash
# 1. Install ArgoCD via Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=30080 \
  --set server.service.nodePortHttps=30443 \
  --set 'server.extraArgs[0]=--insecure' \
  --set configs.params.server\\.insecure=true \
  --set dex.enabled=false \
  --set notifications.enabled=false

# 2. Wait for ArgoCD to be ready
kubectl -n argocd rollout status deploy/argocd-server

# 3. Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

# 4. Apply the ArgoCD Applications (argocd self-manages + nginx)
kubectl apply -f https://raw.githubusercontent.com/gjed/workshop-2026-k8s/main/argocd/argocd.yaml
kubectl apply -f https://raw.githubusercontent.com/gjed/workshop-2026-k8s/main/argocd/nginx.yaml

# 5. ArgoCD UI is available at http://<MASTER_IP>:30080
```

### Adopting the existing nginx deployment under ArgoCD

If nginx is already running and you want ArgoCD to adopt it (no downtime):

```bash
# Just apply the ArgoCD Application -- it will detect the existing resources and adopt them
kubectl apply -f https://raw.githubusercontent.com/gjed/workshop-2026-k8s/main/argocd/nginx.yaml
```

ArgoCD will compare the live state with the repo manifests and reconcile any drift.

### Or: clean slate (delete existing, let ArgoCD recreate)

```bash
kubectl delete deploy nginx -n default
kubectl apply -f https://raw.githubusercontent.com/gjed/workshop-2026-k8s/main/argocd/nginx.yaml
```
