#!/usr/bin/env bash

SECRET_NAME="$1"
NAMESPACE="$2"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

KUBECTL=$(command -v "${BIN_DIR}/kubectl" || command -v kubectl)
if [[ -z "${KUBECTL}" ]]; then
  echo "kubectl cli not found"
  exit 1
fi

OC=$(command -v "${BIN_DIR}/oc" || command -v oc)
if [[ -z "${OC}" ]]; then
  echo "oc cli not found"
  exit 1
fi

${KUBECTL} describe sealedsecret "${SECRET_NAME}" -n "${NAMESPACE}"

${KUBECTL} get secret "${SECRET_NAME}" -n "${NAMESPACE}" || exit 1

${OC} extract "secret/${SECRET_NAME}" -n "${NAMESPACE}" --to=-
