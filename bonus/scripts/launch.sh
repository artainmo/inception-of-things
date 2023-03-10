kubectl cluster-info &>/dev/null
if [ $? -eq 1 ] #protect this script from running without an active kubernetes cluster
then
	if [ "$(uname)" = "Darwin" ]; then
		osascript -e 'display notification "Argo-CD launched without a kubernetes cluster" with title "App Error"'; say "App Error"
	fi
  echo "An error occurred. No kuberneted cluster is running for Argo-CD to be launched."
  read -p 'Do you want us to first create the cluster? (y/n): ' input
	if [ $input = 'y' ]; then
		./scripts/setup.sh
	fi
	exit 0
fi

if [ -z "$1" ]; then
  	echo "\033[0;32m======== Argo CD setup - Allow the creation of a CI/CD pipeline around kubernetes application ========\033[0m"
fi
echo "WAITING FOR ARGO-CD PODS TO RUN... (This can take up to 6minutes)"
if [ "$1" ]; then
  sleep 10 #This is necessary as we cannot check the argo-cd pods instantly after applying them
fi
SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
kubectl wait pods -n argocd --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ]
then
	if [ "$(uname)" = "Darwin" ]; then
		osascript -e 'display notification "Argo-CD pods creation timeout" with title "App Error"'; say "App Error"
	fi
  echo "An error occurred. The creation of argocd's pods timed out."
	echo "We will delete the k3d cluster..."
	k3d cluster delete p3
	exit 1
fi
if [ "$(uname)" = "Darwin" ]; then
	echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed since waiting for Argo-CD pods creation."
else
	echo "$(($SECONDS / 60)) minutes and $(expr $SECONDS % 60) seconds elapsed since waiting for Argo-CD pods creation."
fi

kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null #We delete port-forward process if it already exists
kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null & #We run it in background and hide the output because benign error messages and other undesirable messages appear from it
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
ARGOCD_ADDRESS="$(kubectl get services --namespace=argocd argocd-server --output=jsonpath="{.spec.clusterIP}"):443"
argocd login localhost:9393 --username admin --password $ARGOCD_PASSWORD --insecure --grpc-web
kubectl config set-context --current --namespace=argocd
argocd app create will --repo 'https://gitlab.com/artainmo/inception-of-things.git' --path 'app' --dest-namespace 'dev' --dest-server 'https://kubernetes.default.svc' --grpc-web
if [ $? -eq 20 ] #protect this script from running while will app already exists
then
  echo "An error occurred when creating argo-cd app 'will'."
  echo "Probably because the argo-cd app 'will' already exists."
  read -p 'Do you want us to delete and recreate the app? (y/n): ' input
	if [ $input = 'y' ]; then
		echo "We will delete the app for you."
		yes | argocd app delete will --grpc-web &>/dev/null
		echo "Now we will relaunch argo-cd for you."
		./scripts/launch.sh
		exit 0
	fi
	exit 1
fi
echo "\033[0;36mView created app before sync and configuration\033[0m"
argocd app get will --grpc-web
sleep 5 #Those pauses between argocd calls help prevent connection bugs
echo "\033[0;36mSync the app and configure\033[0m"
argocd app sync will --grpc-web
sleep 5
#In this 'bonus' exercise we will sync through GitLab CI/CD calling 'argocd app sync will'. Thus we remove automated sync.
#echo "> set automated sync policy"
#argocd app set will --sync-policy automated --grpc-web #Once git repo is changed with new push, our running will-app will mirror that.
#sleep 5
#auo-prune cannot be set without automated sync
#echo "> set auto-prune policy"
#argocd app set will --auto-prune --allow-empty --grpc-web #If resources are removed in git repo those resources will also be removed inside our running will-app, even if that means the app becomes empty.
#sleep 5
#echo "> set self-heal policy" #I remove this policy because it is of no utility inside this project while I suspect it to (as a bug) revert new syncs to older versions sometimes.
#argocd app set will --self-heal --grpc-web #If between git repo changes the running app changes (because you remove certain of its resources per accident or for other reasons...) the running app will be reverted to the lastest git repo's version.
#sleep 5
echo "\033[0;36mView created app after sync and configuration\033[0m"
argocd app get will --grpc-web


echo "\033[0;32m======== BONUS: Install GitLab runner in kubernetes cluster with helm ========\033[0m"
git clone https://gitlab.com/artainmo/inception-of-things.git tmp &>/dev/null
sleep 5
cd tmp
if [ "$(uname)" = "Linux" ]; then #View on linux file not found bug
   pwd
   ls -la
fi
if [ "$(uname)" = "Darwin" ]; then
	git push --dry-run &>/dev/null #verify you have the permissions to make changes to this repo
	if [ $? -eq 128 ]
	then
	  echo "You don't have the permissions to make changes in repo. You won't be able to verify synchronization."
	  cd -; rm -rf tmp;
	  exit 1
	fi
fi
echo "\033[1;33mBefore giving GitLab ARGOCD_PASSWORD and ARGOCD_ADDRESS\033[0m"
cat .gitlab-ci.yml | grep 'ARGOCD_PASSWORD:'
cat .gitlab-ci.yml | grep 'ARGOCD_ADDRESS:'
if [ "$(uname)" = "Darwin" ]; then
   sed -i '' "s/ARGOCD_PASSWORD:.*/ARGOCD_PASSWORD: '$ARGOCD_PASSWORD'/g" .gitlab-ci.yml
   sed -i '' "s/ARGOCD_ADDRESS:.*/ARGOCD_ADDRESS: '$ARGOCD_ADDRESS'/g" .gitlab-ci.yml
else
   sed --i "s/ARGOCD_PASSWORD:.*/ARGOCD_PASSWORD: '$ARGOCD_PASSWORD'/g" .gitlab-ci.yml
   sed --i "s/ARGOCD_ADDRESS:.*/ARGOCD_ADDRESS: '$ARGOCD_ADDRESS'/g" .gitlab-ci.yml
fi
echo "\033[1;33mAfter giving GitLab ARGOCD_PASSWORD and ARGOCD_ADDRESS\033[0m"
cat .gitlab-ci.yml | grep 'ARGOCD_PASSWORD:'
cat .gitlab-ci.yml | grep 'ARGOCD_ADDRESS:'
git add .gitlab-ci.yml
sleep 2
git commit -m "setting latest ARGOCD_PASSWORD and ARGOCD_ADDRESS"
sleep 2
git push
sleep 3
cd - 1>/dev/null
rm -rf tmp
echo "\033[0;36mCreate gitlab-runner\033[0m"
kubectl config set-context --current --namespace=gitlab
helm repo add gitlab https://charts.gitlab.io
helm install --namespace 'gitlab' gitlab-runner \
			--set gitlabUrl='https://gitlab.com/',runnerRegistrationToken='GR1348941ZsiMGEXKMKDvmWx4ysQF',rbac.create='true' \
			gitlab/gitlab-runner
echo "\033[0;36mWAIT until the gitlab-runner pod is ready... (This can take up to 3minutes)\033[0m"
SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
kubectl wait pods -n gitlab --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ]; then
  if [ "$(uname)" = "Darwin" ]; then
	   osascript -e 'display notification "Launch timeout" with title "App Error"'; say "App Error"
  fi
  echo "An error occurred. Gitlab-runner takes abnormally long to launch."
	exit 1
fi
if [ "$(uname)" = "Darwin" ]; then
	echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed since waiting for gitlab pods creation."
else
	echo "$(($SECONDS / 60)) minutes and $(expr $SECONDS % 60) seconds elapsed since waiting for gitlab pods creation."
fi
echo "\033[0;36mView created GitLab Runner\033[0m"
#helm status gitlab-runner
kubectl describe pods gitlab-runner --namespace=gitlab
if [ "$(uname)" = "Darwin" ]; then
	osascript -e 'display notification "GitLab configuration is finished" with title "App Ready"'; say "App Ready"
fi
read -p 'Do you want to view the gitlab-runner from gitlab? (y/n): ' input
if [ $input = 'y' ]; then
	echo " When arrived on page expand 'Runners' and see 'Project runners', 'Assigned project runners'."
	if [ "$(uname)" = "Darwin" ]; then
		for i in {10..0}; do
	      printf ' We will redirect you to https://gitlab.com/artainmo/inception-of-things/-/settings/ci_cd in: \033[0;31m%d\033[0m \r' $i #An empty space must sit before \r else prior longer string end will be displayed
	  		sleep 1
		done
		printf '\n'
		open 'https://gitlab.com/artainmo/inception-of-things/-/settings/ci_cd'
	else
		printf ' If logged on gitlab go here https://gitlab.com/artainmo/inception-of-things/-/settings/ci_cd\n'
		sleep 20
	fi
fi

./scripts/verify.sh 'called_from_launch' $1
exit 0
