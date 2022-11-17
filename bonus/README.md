# Introduction
This app launches a kubernetes cluster using [k3d](https://github.com/artainmo/WebDevelopment/blob/main/other/kubernetes/README.md#k3d---launch-local-kubernetes-cluster) wherein [Argo-CD](https://github.com/artainmo/WebDevelopment/blob/main/other/kubernetes/README.md#argo-cd) is used to synchronize the running kubernetes cluster with a [git repository](https://github.com/Aglorios17/Inception_Of_Things_19/tree/main/p3/app) containing kubernetes configuration files to run as an app inside the kubernetes cluster. This automates moving files from a development to production environment and is part of the [CI/CD pipeline](https://github.com/artainmo/WebDevelopment/tree/main/other/DevOps#CICD-pipelines).

# Use
### Prerequisites
Use on macOS. This has been developed on Monterey version 12.6.<br>
Run Docker Desktop.<br>
Have 'brew' ready.<br>

### Start
```
make
```
Restart the whole app with `make re`.<br>
Remove the app and clean workspace with `make clean`.<br>

For more advanced commands look at the makefile.
