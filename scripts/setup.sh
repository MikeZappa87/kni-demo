#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind.yaml --name test1
kubectl cluster-info --context kind-test1

kind load docker-image kni-network-runtime:latest --name test1

kubectl apply -f ./runtime-ds.yaml

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-
# wait for all k8s resources
sleep 10
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubectl get pods -A
