#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"

if [[ -z "${BIN_DIR}" ]]; then
  mkdir -p ./bin
  BIN_DIR=$(cd ./bin; pwd -P)
fi

HELM=$(command -v helm || command -v ${BIN_DIR}/helm)

if [[ -z "${HELM}" ]]; then
  curl -sLo helm.tar.gz https://get.helm.sh/helm-v3.6.1-linux-amd64.tar.gz
  tar xzf helm.tar.gz
  mv ./linux-amd64/helm ${BIN_DIR}/helm
  rm -rf linux-amd64
  rm helm.tar.gz

  HELM="${BIN_DIR}/helm"
fi

${HELM} uninstall sealed-secrets -n "${NAMESPACE}"
