#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

PATH=$PWD/bin

# Build image
docker build debugger \
	--file debugger/Dockerfile \
	--tag docker.io/dlipovetsky/debugger:v1.0

# Load image into cluster
minikube image load docker.io/dlipovetsky/debugger:v1.0
