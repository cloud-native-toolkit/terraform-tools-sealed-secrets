#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"
SECRET_NAME="$2"

# Check for CRD
CREATE_CRD="true"
if ! kubectl explain sealedsecretcontroller.bitnami.com 1> /dev/null 2> /dev/null; then
  echo "CRDs already installed. Setting CREATE_CRD flag to false"
  CREATE_CRD="false"
fi

cat "${CONFIG_DIR}/instance.yaml" | \
  sed "s/CREATE_CRD/${CREATE_CRD}/g" | \
  sed "s/SEALED_SECRET_KEY/${SECRET_NAME}/g" | \
  kubectl apply -n "${NAMESPACE}" -f -
