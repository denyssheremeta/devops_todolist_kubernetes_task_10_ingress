# Setup and Validation Guide

# Create kind cluster

```
kind create cluster --config ./.infrastructure/cluster.yml
kubectl get nodes # wait until all nodes are Ready
```

# Install ingress-nginx controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx get pods # wait until controller pods are Ready
```

# Deploy the app

```
./bootstrap.sh
kubectl -n todo get deploy,svc # wait until all todo namespace resources are Ready
```

# Validate ingress created and bound

```
kubectl -n todo get ingress todo-web -o wide
kubectl -n todo get ingress todo-web -o yaml | grep -E "host:|path:|use-regex|rewrite-target"
```

# Access from host

```
curl -I http://localhost
curl -sSf http://localhost/ | head -n 5
```

## Check no 404s

## Open http://localhost in a browser → DevTools → Network → verify no 404.

# Additionally test key paths:

```
for p in / /static/ /api/health; do curl -s -o /dev/null -w "%{http_code} $p\n" http://localhost$p; done
```

## responses should be 200 or 30x (but not 404)

# Diagnostics in case of problems

```
kubectl -n todo describe ingress todo-web
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=200
kubectl -n todo get endpoints todo-svc -o yaml
```
