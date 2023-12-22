# kni-demo


mkdir -p bin

#containerd
CGO_ENABLED=0 make binaries && cp ./bin/containerd ../bin/bin

#kubelet
CGO_ENABLED=0 make WHAT='cmd/kubelet' && cp ./_output/bin/kubelet ../bin/bin

#kni server
task build-server && cp ./bin/server ../bin/bin