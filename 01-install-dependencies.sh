#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Check system-wide dependencies
for dep in code curl docker git timeout xargs; do
	if ! command -v $dep >/dev/null; then
		printf "%s\n" "Before running $0, install $dep"
	fi
done

# Create directory to store local dependencies
mkdir -p bin

# Install minikube
command -v bin/minikube ||
	curl -L -o bin/minikube https://storage.googleapis.com/minikube/releases/v1.29.0/minikube-linux-amd64
chmod u+x bin/minikube

# Install kubectl
command -v bin/kubectl ||
	curl -L -o bin/kubectl "https://dl.k8s.io/release/v1.26.3/bin/linux/amd64/kubectl"
chmod u+x bin/kubectl

# Install clusterctl
command -v bin/clusterctl ||
	curl -L -o bin/clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.4.1/clusterctl-linux-amd64
chmod u+x bin/clusterctl

# Clone cluster-api repository
git -C cluster-api/ \
	describe --tags v1.4.1 ||
	git clone https://github.com/kubernetes-sigs/cluster-api \
		--depth 1 \
		--branch v1.4.1 \
		cluster-api

# Install go 1.19.6
command -v go/bin/go ||
	{
		curl -L https://go.dev/dl/go1.19.6.linux-amd64.tar.gz &&
			tar zxf go1.19.6.linux-amd64.tar.gz
	}

# Ensure we have local source code for all cluster-api dependencies
(
	cd cluster-api
	go/bin/go mod download
)
(
	cd cluster-api/test
	go/bin/go mod download
)
