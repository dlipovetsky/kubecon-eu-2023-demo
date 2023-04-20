#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

PATH=$PWD/bin

CAPI_POD=$(kubectl -n capi-system get -l=cluster.x-k8s.io/provider=cluster-api,control-plane=controller-manager pod --output=jsonpath='{.items[0].metadata.name}')
bash start-debug-server.sh capi-system "$CAPI_POD" 4440 &

CAPD_POD=$(kubectl -n capd-system get -l=cluster.x-k8s.io/provider=infrastructure-docker,control-plane=controller-manager pod --output=jsonpath='{.items[0].metadata.name}')
bash start-debug-server.sh capd-system "$CAPD_POD" 4441 &

CAPBK_POD=$(kubectl -n capi-kubeadm-bootstrap-system get -l=cluster.x-k8s.io/provider=bootstrap-kubeadm,control-plane=controller-manager pod --output=jsonpath='{.items[0].metadata.name}')
bash start-debug-server.sh capi-kubeadm-bootstrap-system "$CAPBK_POD" 4442 &
