#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAMESPACE="$1"

if [[ "${SKIP}" == "true" ]]; then
  echo "Skipping destroy of sealed secrets"
  exit 0
fi

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v helm 1> /dev/null 2> /dev/null; then
  echo "helm cli not found" >&2
  exit 1
fi

helm uninstall sealed-secrets -n "${NAMESPACE}"
