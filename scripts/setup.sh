#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind.yaml --name test1

kubectl cluster-info --context kind-test1

kubectl scale --replicas=0 -n kube-system deployment coredns
kubectl scale --replicas=0 -n local-path-storage deployment local-path-provisioner

kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=5m

sleep 20

for node in test1-control-plane test1-worker; do
	docker cp ./bin/containerd ${node}:/usr/local/bin/containerd
	docker cp ./bin/network-runtime ${node}:/usr/bin/network-runtime
	docker cp ./bin/kubelet ${node}:/usr/bin/kubelet
	docker cp ./files/kni.service ${node}:/etc/systemd/system/kni.service
	docker cp ./files/config.toml ${node}:/etc/containerd/config.toml

	docker exec ${node} plane systemctl daemon-reload
	docker exec ${node} systemctl start kni
	docker exec ${node} systemctl restart kubelet
	docker exec ${node} systemctl restart containerd
done

kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=5m

kubectl scale --replicas=2 -n kube-system deployment coredns
kubectl scale --replicas=1 -n local-path-storage deployment local-path-provisioner

kubectl delete pods -n kube-system -l "k8s-app=kindnet"

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-

kubectl get pods -A
