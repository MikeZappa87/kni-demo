# kni-demo

## Prerequisite

- [kind](https://github.com/kubernetes-sigs/kind)
- [Task](https://taskfile.dev/)
- [golang](https://go.dev/)


## How to Setup

```
$ git clone https://github.com/MikeZappa87/kni-demo
$ cd kni-demo
$ task 01-init 02-build 03-setup
```

Note: '01-init' and '02-build' are only required initially.

Run Cilium+Network runtime. If libkni is added to cilium, you can package everything in one pod. 

use '03-setup-cilium' instead of '03-setup'

## How to teardown

```
$ task cleanup
```
