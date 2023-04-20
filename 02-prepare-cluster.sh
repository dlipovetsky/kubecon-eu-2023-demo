#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

PATH=$PWD/bin

# Start cluster
minikube start \
	--driver=kvm2 \
	--kubernetes-version=v1.26.3

# Install Cluster API into minikube cluster
CLUSTER_TOPOLOGY=true \
	clusterctl init \
	--infrastructure docker

# To speed up future Cluster API installation, save all images from the cluster into the cache
minikube image ls |
	xargs --verbose --max-args=1 minikube image save

# Ensure minikube VM can run a Docker cluster
# The Docker provider uses the "kind" docker network (https://github.com/kubernetes-sigs/cluster-api/blob/3ad7b0edd07bb6efa5865cf9e69ad0ce560732d9/test/infrastructure/docker/internal/docker/kind_manager.go#L40-L41)
minikube ssh -- docker network create kind

# Generate the cluster manifest
SERVICE_CIDR=["10.96.0.0/12"] POD_CIDR=["192.168.0.0/16"] SERVICE_DOMAIN="k8s.test" \
	clusterctl generate cluster capi-quickstart \
	--flavor development \
	--kubernetes-version v1.26.0 \
	--control-plane-machine-count=1 \
	--worker-machine-count=0 \
	>capi-quickstart.yaml

# Create and access CAPD (Docker provider) cluster inside minikube node
kubectl create -f capi-quickstart.yaml
