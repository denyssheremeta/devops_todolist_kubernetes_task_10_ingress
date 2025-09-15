# Validation checklist

## 1) Cluster and ingress controller

```
kubectl get nodes
kubectl -n ingress-nginx get pods
```

# all controller pods should be Ready

## 2) Apk resources

```
kubectl -n todo get deploy,svc
```

# service todo-svc has port 80 (targetPort = container port)

## 3) Ingress created and bound

```
kubectl -n todo get ingress todo-web -o wide
kubectl -n todo get ingress todo-web -o yaml | grep -E "host:|path:|use-regex|rewrite-target"
```

## 4) Access from host

```
curl -I http://localhost
curl -sSf http://localhost/ | head -n 5
```

## 5) No 404

# in the browser open http://localhost and in DevTools → Network make sure there is no 404

# additionally:

```
for p in / /static/ /api/health; do curl -s -o /dev/null -w "%{http_code} $p\n" http://localhost$p; done
```

# codes should be 200/30x (but not 404)

## 6) Diagnostics in case of problems

```
kubectl -n todo describe ingress todo-web
kubectl -n ingress-nginx logs deploy/ingress-nginx-controller --tail=200
kubectl -n todo get endpoints todo-svc -o yaml # make sure the backend endpoints are
```
