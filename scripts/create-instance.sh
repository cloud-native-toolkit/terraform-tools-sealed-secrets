#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"
SECRET_NAME="$2"

cat "${CONFIG_DIR}/instance.yaml" | \
  sed "s/sealed-secrets-key/${SECRET_NAME}/g" | \
  kubectl apply -n "${NAMESPACE}" -f -
