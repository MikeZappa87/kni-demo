# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# kind node base image
#
# For systemd + docker configuration used below, see the following references:
# https://systemd.io/CONTAINER_INTERFACE/

# start from debian slim, this image is reasonably small as a starting point
# for a kubernetes node image, it doesn't contain much (anything?) we don't need
# this stage will install basic files and packages
ARG BASE_IMAGE=kindest/node@sha256:3966ac761ae0136263ffdb6cfd4db23ef8a83cba8a463690e98317add2c9ba72
FROM $BASE_IMAGE as base
# overwrite
ADD ./bin/containerd /usr/local/bin/containerd
ADD ./bin/kubelet /usr/bin/kubelet
ADD ./bin/bridge /opt/cni/bin/bridge
ADD ./bin/host-local /opt/cni/bin/host-local
ADD ./files/config.toml /etc/containerd/config.toml
ADD ./files/10-ipv6.conf /etc/sysctl.d/10-ipv6.conf

# squash down to one compressed layer, without any lingering whiteout files etc
FROM base
COPY --from=base / /
# add metadata, must be done after the squashing
# first tell systemd that it is in docker (it will check for the container env)
# https://systemd.io/CONTAINER_INTERFACE/
ENV container docker
# systemd exits on SIGRTMIN+3, not SIGTERM (which re-executes it)
# https://bugzilla.redhat.com/show_bug.cgi?id=1201657
STOPSIGNAL SIGRTMIN+3

# NOTE: this is *only* for documentation, the entrypoint is overridden later
ENTRYPOINT [ "/usr/local/bin/entrypoint", "/sbin/init" ]
