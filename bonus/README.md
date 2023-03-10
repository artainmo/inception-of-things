# Introduction
Here we launch a similar app as in part [p3](https://github.com/Aglorios17/Inception_Of_Things_19/tree/main/p3), using [k3d](https://github.com/artainmo/DevOps/tree/main/kubernetes#k3d---launch-local-kubernetes-cluster) for generating a local kubernetes cluster and [Argo-CD](https://github.com/artainmo/DevOps/tree/main/kubernetes#argo-cd) for synchronization between repository and running app.<br>
However here we do not setup Argo CD for 'automatic' synchronization. Instead we acquire automatic synchronization through the use of a [gitlab CI/CD pipeline](https://github.com/artainmo/DevOps/tree/main/gitlab#gitlab-cicd-pipeline) (we defined [here](https://gitlab.com/artainmo/inception-of-things/-/blob/master/.gitlab-ci.yml)) manually executing Argo-CD synchronization each time changes are made inside our [gitlab app repository](https://gitlab.com/artainmo/inception-of-things/-/tree/master/app) that we run inside the cluster.

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
To make the app work on Linux you will have to install the dependencies from 'p3' if not done already. And additionally the one below.
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
