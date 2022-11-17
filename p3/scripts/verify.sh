if [ "$2" ]; then #If scripts started from setup.sh
  osascript -e 'display notification "Argo-CD configuration is finished" with title "App Ready"'; say "App Ready"
fi
if [ -z "$1" ]; then #If scripts was not started by another script
  #We refresh the argo-cd connection because it tends to slow down. After testing it indeed makes everything instantly faster and prevents bugs.
  kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null #We delete port-forward process if it already exists
  kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null & #We run it in background and hide the output because benign error messages and other undesirable messages appear from it
fi

echo "\033[0;32m======== Connect to Argo CD user-interface (UI) ========\033[0m"
read -p 'Do you want to be redirected to the argo-cd UI? (y/n): ' input
if [ $input = 'y' ]; then
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
	echo " ARGO CD USERNAME: admin"
	echo " ARGO CD PASSWORD: $ARGOCD_PASSWORD (we PASTED it on CLIPBOARD if you are on mac)"
	echo $ARGOCD_PASSWORD | pbcopy
	for i in {20..0}; do
      printf ' Remember those credentials. We will redirect you to https://localhost:8080 for the Argo CD UI in: \033[0;31m%d\033[0m \r' $i #An empty space must sit before \r else prior longer string end will be displayed
  		sleep 1
	done
	printf '\n'
	open 'https://localhost:8080'
fi

echo "\033[0;32m======== Verify automated synchronization ========\033[0m"
read -p 'Do you want to push git repo changes to verify if running app synchronizes? (y/n): ' input
if [ $input != 'y' ]; then
	exit 0
fi
echo "WAIT until will-app pods are ready before starting... (This can take up to 4minutes)"
SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
kubectl wait pods -n dev --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ] #protect from pods in dev who are not ready yet before making the verifications
then
	osascript -e 'display notification "will-app pods creation timeout" with title "App Error"'; say "App Error"
  echo "An error occurred. The creation of will-app pods timed out."
	exit 1
fi
echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed since waiting for will-app pods creation."
kubectl config set-context --current --namespace=dev
kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/will-app-service' | cut -d ' ' -f1) 2>/dev/null
#From my understanding we should be able to access the app running in kubernetes from outside by using a service of type LoadBalancer, subsequently calling `curl http://<external-ip>:<port>` (find 'external-ip:port' with `get services -n dev will-app-service`).
#However this did not work for me. To resolve the problem I forwarded the service's access point on localhost:8888. This means by calling localhost:8888 I am redirected to the service which finally redirects me to the pod containing app.
kubectl port-forward svc/will-app-service -n dev 8888:8888 &>/dev/null &
imageVersion=$(kubectl describe deployments will-app-deployment | grep 'Image')
imageVersion=$(echo $imageVersion | cut -c 26-26)
if [ $imageVersion -eq 1 ]; then
  newImageVersion=2
else
  newImageVersion=1
fi
echo "\033[0;36mOur current app uses the version $imageVersion of following image\033[0m"
echo "> kubectl describe deployments will-app-deployment | grep 'Image'"
kubectl describe deployments will-app-deployment | grep 'Image'
echo "> curl http://localhost:8888"
curl http://localhost:8888
echo "\n\033[0;36mNow we will change the git repository Argo-CD is connected to so that the image uses version $newImageVersion instead of $imageVersion\033[0m"
git clone 'https://github.com/Aglorios17/Inception_Of_Things_19.git' tmp &>/dev/null
cd tmp/p3
git push --dry-run &>/dev/null #verify you have the permissions to make changes to this repo
if [ $? -eq 128 ]
then
  echo "You don't have the permissions to make changes in repo. You won't be able to verify synchronization."
  cd -; rm -rf tmp;
  exit 1
fi
realImageVersion=$(cat app/app/deployment.yaml | grep 'image')
realImageVersion=$(echo $realImageVersion | cut -c 26-26)
if [ $imageVersion != $realImageVersion ]; then
  osascript -e 'display notification "Verification not possible" with title "App Error"'; say "App Error"
  echo "We cannot perform the verification as the running app is not synchronized with git repo yet."
  read -p 'Do you want to wait until the running app synchronizes? (y/n): ' input
  if [ $input != 'y' ]; then
    cd -; rm -rf tmp
  	exit 0
  fi
  echo "Waiting... (This can take up to 6minutes)"
  SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
  kubectl wait deployment will-app-deployment --for=jsonpath="{.spec.template.spec.containers[*].image}"="wil42/playground:v$realImageVersion" --timeout=600s
  if [ $? -eq 1 ]
  then
  	osascript -e 'display notification "Synchronization timeout" with title "App Error"'; say "App Error"
    echo "An error occurred. Argo-CD takes abnormally long to synchronize."
    cd -; rm -rf tmp
  	exit 1
  fi
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed since waiting for sync."
  newImageVersion=$imageVersion
  imageVersion=$realImageVersion
fi
echo "\033[1;33mBefore changing deployment.yaml\033[0m"
echo "> cat app/app/deployment.yaml | grep 'image'"
cat app/app/deployment.yaml | grep 'image'
sed -i '' "s/wil42\/playground\:v$imageVersion/wil42\/playground\:v$newImageVersion/g" app/app/deployment.yaml
echo "\033[1;33mAfter changing deployment.yaml\033[0m"
echo "> cat app/app/deployment.yaml | grep 'image'"
cat app/app/deployment.yaml | grep 'image'
git add app/app/deployment.yaml &>/dev/null
git commit -m "App change image version for synchronization TEST" &>/dev/null
git push &>/dev/null
cd - 1>/dev/null
rm -rf tmp
echo "\033[0;36mWAIT until automated synchronization occurs (this can take up to 6minutes)\033[0m\nAvoid manual synchronization as it can lead to bugs during this demonstration."
SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
kubectl wait deployment will-app-deployment --for=jsonpath="{.spec.template.spec.containers[*].image}"="wil42/playground:v$newImageVersion" --timeout=600s
if [ $? -eq 1 ]
then
	osascript -e 'display notification "Synchronization timeout" with title "App Error"'; say "App Error"
  echo "An error occurred. Argo-CD takes abnormally long to synchronize."
	exit 1
fi
echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed since waiting for sync."
echo "\033[0;36mAfter automated synchronization the running app should mirror the git repo and use image version $newImageVersion\033[0m"
echo "> kubectl describe deployments will-app-deployment | grep 'Image'"
kubectl describe deployments will-app-deployment | grep 'Image'
#We make sure to use an open port else bugs sometimes occur if predefined port is already in use.
openPort=8889
while [[ $(lsof -i :$openPort) ]]; do
  ((openPort++))
done
echo "> curl http://localhost:$openPort"
sleep 5 #This prevents the following command from failing for some reason
#The last port-forward is linked to prior app. After synchronization we need to make a new port-forward. We use a new port because trying to keep port 8888 creates bugs even when killing prior port-forward.
kubectl port-forward svc/will-app-service -n dev $openPort:8888 &>/dev/null &
sleep 5 #This prevents the following command from failing for some reason
curl http://localhost:$openPort 2>/dev/null
while [ $? != 0 ]; do #Sometimes bugs occur but relaunching resolves the problem
  echo "Call failed retrying..."
  if ! [[ $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/will-app-service -n dev $openPort') ]]; then #If port-forward does not exist, recreate.
    sleep 5
    kubectl port-forward svc/will-app-service -n dev $openPort:8888 &>/dev/null &
  fi
  sleep 5
  curl http://localhost:$openPort 2>/dev/null
done
osascript -e 'display notification "Synchronization results are ready" with title "Verification finished"'; say "Verification finished"
