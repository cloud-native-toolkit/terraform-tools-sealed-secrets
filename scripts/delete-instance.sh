#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"
SECRET_NAME="$2"

BIN_DIR="./dir"

mkdir -p "${BIN_DIR}"

HELM=$(command -v helm || command -v ./bin/helm)

if [[ -z "${HELM}" ]]; then
  curl -sLo helm.tar.gz https://get.helm.sh/helm-v3.6.1-linux-amd64.tar.gz
  tar xzf helm.tar.gz
  mkdir -p ./bin && mv ./linux-amd64/helm ./bin/helm
  rm -rf linux-amd64
  rm helm.tar.gz

  HELM="$(cd ./bin; pwd -P)/helm"
fi

${HELM} template sealed-secrets sealed-secrets \
  --repo https://bitnami-labs.github.io/sealed-secrets \
  --namespace "${NAMESPACE}" \
  --values "${CONFIG_DIR}/instance-values.yaml" | \
  kubectl delete -n "${NAMESPACE}" -f -
