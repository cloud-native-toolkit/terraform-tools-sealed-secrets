#!/usr/bin/env bash

NAMESPACE="$1"
SECRET_NAME="$2"

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

KUBECTL=$(command -v "${BIN_DIR}/kubectl" || command -v kubectl)
if [[ -z "${KUBECTL}" ]]; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if ${KUBECTL} get secret -n "${NAMESPACE}" "${SECRET_NAME}"; then
  ${KUBECTL} delete secret -n "${NAMESPACE}" "${SECRET_NAME}"
else
  echo "Secret ${NAMESPACE}/${SECRET_NAME} not found"
fi
