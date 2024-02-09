#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind-backwards.yaml --name test1
kubectl cluster-info --context kind-test1

kind load docker-image kni-network-runtime:latest --name test1

kubectl apply -f ./backwards-cilium.yaml

helm repo add cilium https://helm.cilium.io/

docker pull quay.io/cilium/cilium:v1.15.0
kind load docker-image quay.io/cilium/cilium:v1.15.0 --name test1

helm install cilium cilium/cilium --version 1.15.0 \
   --namespace kube-system \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-
