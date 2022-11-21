echo "\033[0;32m======== Install prerequisites ========\033[0m"
#do not forget to run docker desktop on mac
#install docker if docker does not exist or is outdated
brew outdated --cask docker || brew install --cask docker
#install kubernetes and its CLI
brew outdated kubernetes-cli || brew install kubernetes-cli
#install k3d
brew outdated k3d || brew install k3d
#install argo-cd's CLI
brew outdated argocd || brew install argocd
#install helm for GitLab Runner on kubernetes
brew outdated helm || brew install helm

echo "\033[0;32m======== K3D setup - Create kubernetes cluster on local machine ========\033[0m"
k3d cluster create p3
if [ $? -eq 1 ]
then
	osascript -e 'display notification "Cluster creation failed" with title "App Error"'; say "App Error"
  echo "An error occured when creating the cluster."
	echo "The cluster probably already exists."
	read -p 'Do you want us to delete and restart the cluster? (y/n): ' input
	if [ $input = 'y' ]; then
		echo "We will delete the cluster for you."
		k3d cluster delete p3
		echo "Now we will restart the cluster for you."
		./scripts/setup.sh
		exit 0
	fi
	exit 1
fi
kubectl cluster-info

echo "\033[0;32m======== Kubernetes namespaces setup ========\033[0m"
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab
kubectl get namespace

echo "\033[0;32m======== Argo CD setup - Allow the creation of a CI/CD pipeline around kubernetes application ========\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
./scripts/launch.sh 'called_from_setup'
exit 0
