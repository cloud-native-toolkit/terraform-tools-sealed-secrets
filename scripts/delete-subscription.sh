#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"

echo "Creating subscription"
oc delete -n "${NAMESPACE}" -f "${CONFIG_DIR}/subscription.yaml"
