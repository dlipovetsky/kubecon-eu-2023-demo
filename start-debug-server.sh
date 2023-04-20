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
PORT=$3

println_with_name() {
	printf 2>&1 "[%s] %s\n" "$POD_NAMESPACE/$POD_NAME" "$1"
}

{
	println_with_name "Starting debug server"
	# Do not check if dlv is already running. It already is, but it's a zombie.
	# TODO Find a way to check this.
	kubectl exec -n "$POD_NAMESPACE" "$POD_NAME" --container=debugger -- \
		sh -c '
                dlv \
                --headless \
                --accept-multiclient \
                --api-version=2 \
                --listen \
                127.0.0.1:2160 \
                attach \
                --continue \
                --log \
                --log-dest=dlv.log \
                1 \
                & \
                '
}

{
	println_with_name "Starting debug proxy"
	kubectl port-forward -n "$POD_NAMESPACE" "$POD_NAME" "$PORT":2160
}
