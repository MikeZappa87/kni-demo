#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind.yaml --name test1
kubectl cluster-info --context kind-test1

kind load docker-image gchr.io/mikezappa87/flannel:KNI-POC --name test1

kubectl apply -f https://raw.githubusercontent.com/MikeZappa87/flannel/kni-flannel-poc/Documentation/kube-flannel.yml

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-
