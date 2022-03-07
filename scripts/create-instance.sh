#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

NAMESPACE="$1"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

HELM=$(command -v "${BIN_DIR}/helm" || command -v helm)
if [[ -z "${HELM}" ]]; then
  echo "helm cli not found" >&2
  exit 1
fi

KUBECTL=$(command -v "${BIN_DIR}/kubectl" || command -v kubectl)
if [[ -z "${KUBECTL}" ]]; then
  echo "kubectl cli not found" >&2
  exit 1
fi

echo "Installing sealed secrets controller"
${HELM} upgrade -i \
  sealed-secrets \
  "${CHART_DIR}/sealed-secrets" \
  -n "${NAMESPACE}"

echo "Waiting for deployment/sealed-secrets in ${NAMESPACE}"
${KUBECTL} rollout status deployment sealed-secrets -n "${NAMESPACE}"
