# Setup and Validation Guide

> **Assumptions**
>
> - Namespace: `todoapp`
> - Deployment: `todoapp` (containerPort `8080`)
> - Service: `todo-svc` (port `80` → targetPort `8080`)
> - Ingress: `todo-web` (class `nginx`, host `localhost`)
> - kind cluster config at `./.infrastructure/cluster.yml`
> - `bootstrap.sh` deploys only app resources (Namespace/ConfigMap/Secret/PVC/Deployment/Service/Ingress) — it **does not** install ingress-nginx controller (we do it here).

---

## 1) Create kind cluster

```bash
set -euo pipefail

# Create cluster with the intended config
kind create cluster --config ./.infrastructure/cluster.yml

# Wait for nodes to be Ready (explicit)
kubectl wait --for=condition=Ready --timeout=180s node --all

# Show nodes
kubectl get nodes -o wide
```

# Install controller (official manifest for kind)

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

# Wait until controller pods are Ready

```
kubectl -n ingress-nginx wait --for=condition=Ready pod -l app.kubernetes.io/name=ingress-nginx --timeout=300s
```

# Confirm controller is up

```
kubectl -n ingress-nginx get deploy,po,svc -o wide
```

# Apply your app stack (should create NS `todoapp` and all resources)

```
./bootstrap.sh
```

# Work in the target namespace by default

```
kubectl config set-context --current --namespace=todoapp
```

# Wait for Deployment rollout

```
kubectl rollout status deploy/todoapp --timeout=300s
```

# Inspect core resources

```
kubectl get deploy,po,svc,ingress,endpoints -o wide
```

# Check Ingress object and key annotations/paths

```
kubectl get ingress todo-web -o wide
kubectl get ingress todo-web -o yaml | grep -E "ingressClassName:|host:|path:|use-regex|rewrite-target"
```

# Confirm Service has Endpoints (i.e., selector matches Pods and Pods are Ready)

```
kubectl get endpoints todo-svc -o wide
```

# Basic reachability

```
curl -I http://localhost
curl -sSf http://localhost/ | head -n 5
```

# No 404s on key paths

```
for p in / /static/ /api/health; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost$p")
  printf "%3s  %s\n" "$code" "$p"
done
```

# Responses should be 200 or 30x (but not 404)

# 1) Ingress+controller

```
kubectl describe ingress todo-web
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=200
```

# 2) Service and Endpoints

```
kubectl get svc todo-svc -o yaml
kubectl get endpoints todo-svc -o yaml
```

# 3) Pod readiness

```
kubectl get po -o wide --show-labels
kubectl describe po -l app=todoapp
kubectl logs deploy/todoapp --tail=200
```

# 4) Direct app check (bypass Ingress)

```
kubectl port-forward deploy/todoapp 8080:8080 &
sleep 2
curl -I http://127.0.0.1:8080/
```
