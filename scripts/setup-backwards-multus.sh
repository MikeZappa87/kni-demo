#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind-backwards.yaml --name test1
kubectl cluster-info --context kind-test1

kind load docker-image kni-network-runtime:latest --name test1

kubectl apply -f ./backwards-kni.yaml

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-

kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml