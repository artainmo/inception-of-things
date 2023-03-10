#!/bin/bash

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -

sleep 20

kubectl apply -n kube-system -f /vagrant/app1.yaml --validate=false
kubectl apply -n kube-system -f /vagrant/app2.yaml --validate=false
kubectl apply -n kube-system -f /vagrant/app3.yaml --validate=false
kubectl apply -n kube-system -f /vagrant/ingress.yaml --validate=false

