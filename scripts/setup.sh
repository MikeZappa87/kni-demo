#!/usr/bin/env bash
set -e
set -o pipefail

kind delete cluster --name test1 || true

kind create cluster --config kind.yaml --name test1

kubectl cluster-info --context kind-test1

kubectl scale --replicas=0 -n kube-system deployment coredns
kubectl scale --replicas=0 -n local-path-storage deployment local-path-provisioner
kubectl -n kube-system wait --for=delete -l k8s-app=kube-dns pod --timeout=5m
kubectl -n local-path-storage wait --for=delete -l app=local-path-provisioner pod --timeout=5m

for node in test1-control-plane test1-worker; do
	docker cp ./bin/containerd ${node}:/usr/local/bin/containerd
	docker cp ./bin/network-runtime ${node}:/usr/bin/network-runtime
	docker cp ./bin/kubelet ${node}:/usr/bin/kubelet
	docker cp ./files/kni.service ${node}:/etc/systemd/system/kni.service
	docker cp ./files/config.toml ${node}:/etc/containerd/config.toml
	docker cp ./bin/bridge ${node}:/opt/cni/bin/bridge
	docker cp ./bin/host-local ${node}:/opt/cni/bin/host-local

	docker exec ${node} systemctl daemon-reload
	docker exec ${node} systemctl start kni
	docker exec ${node} systemctl restart kubelet
	docker exec ${node} systemctl restart containerd
	docker exec ${node} sysctl -w net.ipv6.conf.all.disable_ipv6=0
done

# wait for kubelet again...
sleep 10

kubectl scale --replicas=2 -n kube-system deployment coredns
kubectl scale --replicas=1 -n local-path-storage deployment local-path-provisioner

kubectl taint node test1-control-plane node-role.kubernetes.io/control-plane:NoSchedule-

# wait for all k8s resources
sleep 10
kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=5m

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubectl get pods -A
