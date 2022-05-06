#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../charts"; pwd -P)

NAMESPACE="$1"
CREATED_BY="$2"

if [[ "${SKIP}" == "true" ]]; then
  echo "Skipping sealed secret instance install"
  exit 0
fi

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/sealed-secrets"
fi
mkdir -p "${TMP_DIR}"

if ! command -v helm 1> /dev/null 2> /dev/null; then
  echo "helm cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if ! command -v kustomize 1> /dev/null 2> /dev/null; then
  echo "kustomize cli not found" >&2
  exit 1
fi

KUSTOMIZE_DIR="${TMP_DIR}/kustomize"

mkdir -p "${KUSTOMIZE_DIR}"

cat <<EOT >> "${KUSTOMIZE_DIR}/kustomization.yaml"
resources:
  - all.yaml
commonLabels:
  created-by: ${CREATED_BY}
EOT

cat <<EOT >> "${KUSTOMIZE_DIR}/kustomize"
#!/bin/bash
cat <&0 > all.yaml
kustomize build . && rm all.yaml
EOT

chmod +x "${KUSTOMIZE_DIR}/kustomize"

cd "${KUSTOMIZE_DIR}"

echo "Installing sealed secrets controller"
helm upgrade -i \
  sealed-secrets \
  "${CHART_DIR}/sealed-secrets" \
  -n "${NAMESPACE}" \
  --post-renderer ./kustomize

echo "Waiting for deployment/sealed-secrets in ${NAMESPACE}"
kubectl rollout status deployment sealed-secrets -n "${NAMESPACE}"
