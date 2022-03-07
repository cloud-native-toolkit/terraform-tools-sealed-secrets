#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAMESPACE="$1"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

HELM=$(command -v "${BIN_DIR}/helm" || command -v helm)
if [[ -z "${HELM}" ]]; then
  echo "helm cli not found" >&2
  exit 1
fi

${HELM} uninstall sealed-secrets -n "${NAMESPACE}"
