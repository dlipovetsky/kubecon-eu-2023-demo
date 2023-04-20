#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

PATH=$PWD/bin

# VERBOSE is optional, and defaults to "false"
if [ "${VERBOSE:=false}" == "true" ]; then
	# From https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
	export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
	set -o verbose
	set -o xtrace
else
	export PS4=''
	set +o verbose
	set +o xtrace
fi

POD_NAMESPACE=$1
POD_NAME=$2
TARGET_CONTAINER_NAME=$3

println_with_name() {
    printf 2>&1 "[%s] %s\n" "$POD_NAMESPACE/$POD_NAME" "$1"
}

URL="localhost:8001/api/v1/namespaces/$POD_NAMESPACE/pods/$POD_NAME/ephemeralcontainers"
PATCH=$(cat <<EOF
{
  "spec": {
    "ephemeralContainers": [
      {
        "image": "docker.io/dlipovetsky/debugger:v1.0",
        "name": "debugger",
        "command": [
          "sleep"
        ],
        "args": [
          "infinity"
        ],
        "tty": true,
        "stdin": true,
        "securityContext": {
          "capabilities": {
            "add": [
              "SYS_PTRACE"
            ]
          },
          "runAsNonRoot": false,
          "runAsUser": 0,
          "runAsGroup": 0
        },
        "targetContainerName": "$TARGET_CONTAINER_NAME"
      }
    ]
  }
}
EOF
)

{
	println_with_name "Creating debugger container"

	TERMINATED=$(kubectl -n "$POD_NAMESPACE" get pod "$POD_NAME" --output=jsonpath='{ .status.ephemeralContainerStatuses[?(@.name == "debugger")].state.terminated }')
	if [ "$TERMINATED" != "" ]; then
		println_with_name "Debugger container already exited."
		exit 1
	fi

	RUNNING=$(kubectl -n "$POD_NAMESPACE" get pod "$POD_NAME" --output=jsonpath='{ .status.ephemeralContainerStatuses[?(@.name == "debugger")].state.running }')
	if [ "$RUNNING" != "" ]; then
		println_with_name "Debugger container already running."
	else
		kubectl proxy --address 127.0.0.1 --port 8001 &

		echo "$PATCH" | curl \
			--silent \
			--retry 5 \
			--retry-delay 1 \
			--retry-connrefused \
			"$URL" \
			-XPATCH \
			-H 'Content-Type: application/strategic-merge-patch+json' \
			-d @- \
			>/dev/null

		kill %1
	fi
}

{
	println_with_name "Wait for debugger container to be ready"
	EXEC_TRIES=1
	until
		[ $EXEC_TRIES -gt 5 ] || kubectl exec -n "$POD_NAMESPACE" "$POD_NAME" --container=debugger -- sh
	do
		sleep 1
		EXEC_TRIES=$((EXEC_TRIES + 1))
	done
    println_with_name "Debugger container is ready"
}
