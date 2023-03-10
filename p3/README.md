# Introduction
This app launches a kubernetes cluster using [k3d](https://github.com/artainmo/DevOps/tree/main/kubernetes#k3d---launch-local-kubernetes-cluster) wherein [Argo-CD](https://github.com/artainmo/DevOps/tree/main/kubernetes#argo-cd) is used to synchronize the running kubernetes cluster with a [git repository](https://github.com/Aglorios17/Inception_Of_Things_19/tree/main/p3/app) containing kubernetes configuration files to run as an app inside the kubernetes cluster. This automates moving files from a development to production environment and is part of the [CI/CD pipeline](https://github.com/artainmo/DevOps#CICD-pipelines).

# Use
### Prerequisites
Use on macOS. This has been developed on Monterey version 12.6.<br>
Run Docker Desktop.<br>
Have 'brew' ready.<br>

Or it can also work on Linux. See more below.

### Start
```
make
```
Restart the whole app with `make re`.<br>
Remove the app and clean workspace with `make clean`.<br>

For more advanced commands look at the makefile.

### Linux
To make the app work on Linux here are some of the dependencies that you will have to install manually.
```
sudo apt install make
sudo apt install xsel
sudo apt install gh
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```
However you can also use the script found in 'utils' directory.
