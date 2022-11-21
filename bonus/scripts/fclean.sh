helm delete --namespace gitlab gitlab-runner 2>/dev/null
kubectl delete pod --namespace gitlab $(kubectl get pods -o name | cut -d '/' -f2) 2>/dev/null
k3d cluster delete p3
