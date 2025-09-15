# ... your existing app and service deployment in the todo namespace

# apply ingress
kubectl apply -f ./infrastructure/ingress/ingress.yml

# (optional, but useful) wait for the controller to pick up the Ingress
kubectl -n todo get ingress todo-web