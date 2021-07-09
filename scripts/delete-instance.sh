#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"
SECRET_NAME="$2"

kubectl delete -n "${NAMESPACE}" -f "${CONFIG_DIR}/instance.yaml"
