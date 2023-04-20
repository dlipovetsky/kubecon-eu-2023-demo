# Breakpoints in Your Pod Demo

## Install dependencies

First, you'll need to [install VS Code](https://code.visualstudio.com/download).

Also, make sure you have these utilities:

- bash
- command
- curl
- docker
- git
- sed
- timeout
- xargs

Run this to install remaining dependencies:

```console
bash 01-install-dependencies.sh
```

## Prepare the minikube cluster

```console
bash 02-prepare-cluster.sh
```

## Patch Cluster API Deployments

```console
bash 03-patch-deployments.sh
```

## Create debugger containers

```console
bash 04-create-debugger-container.sh
```

## Start debug servers

```console
bash 05-start-debug-servers.sh
```

## Configure the Go root used for the demo

```console
sed "s|__REPO_ROOT_DIR__|$PWD/go|g" vscode-files/demo.code-workspace.tmpl > vscode-files/demo.code-workspace
```

## Start VS Code

Open the Cluster API workspace:

```console
code vscode-files/demo.code-workspace
```

## Install the vscode-go Extension

Follow the official [instructions](https://marketplace.visualstudio.com/items?itemName=golang.Go).

## Set breakpoints

Open VS Code to these lines, and set breakpoints:

```console
code --goto cluster-api/bootstrap/kubeadm/internal/controllers/kubeadmconfig_controller.go:521
code --goto cluster-api/internal/controllers/machine/machine_controller_noderef.go:91
code --goto infrastructure/docker/internal/docker/machine.go:232
```

## Connect to the debug servers in the 3 Pods

Use the VS Code debug UI to "run and debug" each of three launch configurations.

## Scale worker machines up by 1

```console
bin/kubectl patch cluster capi-quickstart --type json --patch '[{"op": "replace", "path": "/spec/topology/workers/machineDeployments/0/replicas",  "value": 1}]'
```

## Step through the code
