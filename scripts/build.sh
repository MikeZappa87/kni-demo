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

pushd kni-network-runtime
task build-server && cp ./bin/network-runtime ${BINDIR}
popd

pushd plugins
CGO_ENABLED=0 ./build_linux.sh && cp ./bin/bridge ${BINDIR} && cp ./bin/host-local ${BINDIR}
popd
