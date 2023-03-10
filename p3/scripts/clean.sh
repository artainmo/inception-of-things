kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null
#Refresh argo-cd connection to make sure it exists
kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null &
sleep 5 #Wait else following command bugs
#Delete the app (clean)
yes | argocd app delete will --grpc-web &>/dev/null
kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null
