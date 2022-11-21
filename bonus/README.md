# Introduction
Here we launch a similar app as in part [p3](https://github.com/artainmo/inception-of-things/tree/master/p3), using [k3d](https://github.com/artainmo/WebDevelopment/blob/main/other/kubernetes/README.md#k3d---launch-local-kubernetes-cluster) for generating a local kubernetes cluster and [Argo-CD](https://github.com/artainmo/WebDevelopment/blob/main/other/kubernetes/README.md#argo-cd) for synchronization between repository and running app.<br>
However here we do not setup Argo CD for 'automatic' synchronization. Instead we acquire automatic synchronization through the use of a [gitlab CI/CD pipeline](https://github.com/artainmo/WebDevelopment/tree/main/other/DevOps#gitlab-cicd-pipeline) (we defined [here](https://gitlab.com/artainmo/inception-of-things/-/blob/master/.gitlab-ci.yml)) manually executing Argo-CD synchronization each time changes are made inside our [gitlab app repository](https://gitlab.com/artainmo/inception-of-things/-/tree/master/app) that we run inside the cluster.

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
