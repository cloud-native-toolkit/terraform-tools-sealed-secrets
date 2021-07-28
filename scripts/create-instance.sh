#!/usr/bin/env bash


SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"
SECRET_NAME="$2"

mkdir -p ./bin
BIN_DIR=$(cd ./bin; pwd -P)

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

echo "Installing sealed secrets with yaml"
${HELM} template sealed-secrets sealed-secrets \
  --repo https://bitnami-labs.github.io/sealed-secrets \
  --namespace "${NAMESPACE}" \
  --values "${CONFIG_DIR}/instance-values.yaml"

${HELM} template sealed-secrets sealed-secrets \
  --repo https://bitnami-labs.github.io/sealed-secrets \
  --namespace "${NAMESPACE}" \
  --values "${CONFIG_DIR}/instance-values.yaml" | \
  kubectl apply -n "${NAMESPACE}" -f -
