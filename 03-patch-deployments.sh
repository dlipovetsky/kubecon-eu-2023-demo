#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

PATH=$PWD/bin

# Disable leader-election, and remove liveness and readiness probes

CAPI_PATCH='{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"manager"}],"containers":[{"args":["--leader-elect=false","--metrics-bind-addr=localhost:8080","--feature-gates=MachinePool=false,ClusterResourceSet=false,ClusterTopology=true,RuntimeSDK=false,LazyRestmapper=false"],"livenessProbe":null,"name":"manager","readinessProbe":null}]}}}}'
kubectl -n capi-system \
	patch \
	deployment/capi-controller-manager \
	--patch="$CAPI_PATCH"

CAPD_PATCH='{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"manager"}],"containers":[{"args":["--leader-elect=false","--metrics-bind-addr=localhost:8080","--feature-gates=MachinePool=false,ClusterTopology=false"],"livenessProbe":null,"name":"manager","readinessProbe":null}]}}}}'
kubectl -n capd-system \
	patch \
	deployment/capd-controller-manager \
	--patch="$CAPD_PATCH"

CAPBK_PATCH='{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"manager"}],"containers":[{"args":["--leader-elect=false","--metrics-bind-addr=localhost:8080","--feature-gates=MachinePool=false,KubeadmBootstrapFormatIgnition=false,LazyRestmapper=false","--bootstrap-token-ttl=15m"],"livenessProbe":null,"name":"manager","readinessProbe":null}]}}}}'
kubectl -n capi-kubeadm-bootstrap-system \
	patch \
	deployment/capi-kubeadm-bootstrap-controller-manager \
	--patch="$CAPBK_PATCH"
