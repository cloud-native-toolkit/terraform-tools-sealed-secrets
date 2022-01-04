#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

NAMESPACE="$1"

if [[ -z "${BIN_DIR}" ]]; then
  mkdir -p ./bin
  BIN_DIR=$(cd ./bin; pwd -P)
fi

HELM=$(command -v helm || command -v "${BIN_DIR}/helm")

if [[ -z "${HELM}" ]]; then
  curl -sLo helm3.tar.gz https://get.helm.sh/helm-v3.6.1-linux-amd64.tar.gz

  HELM=$(command -v helm || command -v "${BIN_DIR}/helm")
  if [[ -z "${HELM}" ]]; then
    tar xzf helm3.tar.gz
    cp ./linux-amd64/helm "${BIN_DIR}/helm"
    rm -rf linux-amd64
    rm helm3.tar.gz

    HELM="${BIN_DIR}/helm"
  fi
fi

echo "Installing sealed secrets controller"
${HELM} upgrade -i \
  sealed-secrets \
  "${CHART_DIR}/sealed-secrets" \
  -n "${NAMESPACE}"

echo "Waiting for deployment/sealed-secrets in ${NAMESPACE}"
kubectl rollout status deployment sealed-secrets -n "${NAMESPACE}" || \
  kubectl -n "${NAMESPACE}" get events && \
  exit 1
