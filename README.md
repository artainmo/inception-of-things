# inception-of-things

42 school [subject](https://cdn.intra.42.fr/pdf/pdf/66725/en.subject.pdf).

This project I initially made in part with [aglorios](https://github.com/Aglorios17) in this [repository](https://github.com/Aglorios17/Inception_Of_Things_19), I re-uploaded it on my profile.

This project consists of multiple parts.<br>
Part one launches VMs containing K3S (a lightweight kubernetes) with Vagrant.<br>
Part two orchestrates multiple apps with [kubernetes](https://github.com/artainmo/DevOps/tree/main/kubernetes) while using as router an ingress, all inside a VM launched with Vagrant.<br>
Part three synchronizes [github repository](https://github.com/artainmo/inception-of-things/tree/master/p3/app) and kubernetes' running app with [argo-cd](https://github.com/artainmo/DevOps/tree/main/kubernetes#argo-cd)'s automated sync.<br>
The bonus part synchronizes [gitlab repository](https://gitlab.com/artainmo/inception-of-things/-/tree/master/app) and kubernetes' running app via [gitlab CI/CD pipeline](https://github.com/artainmo/DevOps/tree/main/gitlab#gitlab-cicd-pipeline) and argo-cd's manual sync.<br>
