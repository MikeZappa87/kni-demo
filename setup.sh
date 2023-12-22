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

docker cp ./bin/containerd test1-control-plane:/usr/local/bin/containerd
docker cp ./bin/server test1-control-plane:/usr/bin/server
docker cp ./bin/kubelet test1-control-plane:/usr/bin/kubelet
docker cp ./kni.service test1-control-plane:/etc/systemd/system/kni.service
docker cp ./config.toml test1-control-plane:/etc/containerd/config.toml

docker exec test1-control-plane systemctl daemon-reload
docker exec test1-control-plane systemctl start kni
docker exec test1-control-plane systemctl restart kubelet
docker exec test1-control-plane systemctl restart containerd

docker cp ./bin/containerd test1-worker:/usr/local/bin/containerd
docker cp ./bin/server test1-worker:/usr/bin/server
docker cp ./bin/kubelet test1-worker:/usr/bin/kubelet
docker cp ./kni.service test1-worker:/etc/systemd/system/kni.service
docker cp ./config.toml test1-worker:/etc/containerd/config.toml

docker exec test1-worker systemctl daemon-reload
docker exec test1-worker systemctl start kni
docker exec test1-worker systemctl restart kubelet
docker exec test1-worker systemctl restart containerd

kubectl scale --replicas=2 -n kube-system deployment coredns
kubectl scale --replicas=1 -n local-path-storage deployment local-path-provisioner

kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=5m

kubectl get pods -A