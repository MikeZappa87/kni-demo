#!/usr/bin/env bash

# relative path from src to bin
BINDIR="../../bin"
if [ ! -d bin/ ]; then
	mkdir bin
fi

pushd src
pushd containerd
CGO_ENABLED=0 make binaries && cp ./bin/containerd ${BINDIR}
popd

pushd kubernetes
CGO_ENABLED=0 make WHAT='cmd/kubelet' && cp ./_output/bin/kubelet ${BINDIR}
popd

pushd flannel
docker build -f images/Dockerfile --platform=amd64 --build-arg TAG=KNI-POC -t gchr.io/mikezappa87/flannel:KNI-POC .
popd

pushd plugins
CGO_ENABLED=0 ./build_linux.sh && cp ./bin/bridge ${BINDIR} && cp ./bin/host-local ${BINDIR}
popd

pushd kni-network-runtime
docker build -t kni-network-runtime:latest -f Dockerfile .
popd

popd
docker build -t gchr.io/mikezappa87/kni-demo:latest -f images/Dockerfile .
docker build -t gchr.io/mikezappa87/kni-demo-backwards:latest -f images/Dockerfile.backwards .

