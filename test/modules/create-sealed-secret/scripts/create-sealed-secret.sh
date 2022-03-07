#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

SECRET_NAME="$1"
NAMESPACE="$2"
SECRET_VALUE="$3"
SEALED_SECRET_CERT_FILE="$4"
SEALED_SECRET_FILE="$5"

if [[ -z "${SECRET_NAME}" ]] || [[ -z "${SECRET_VALUE}" ]] || [[ -z "${SEALED_SECRET_FILE}" ]] || [[ -z "${SEALED_SECRET_CERT_FILE}" ]]; then
  echo "Usage: create-sealed-secrets.sh SECRET_NAME SECRET_VALUE SEALED_SECRET_CERT_FILE SEALED_SECRET_FILE"
  exit 1
fi

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="/usr/local/bin"
fi

SEALED_SECRET_DIR=$(cd $(dirname "${SEALED_SECRET_FILE}"); pwd -P)
mkdir -p "${SEALED_SECRET_DIR}"

KUBESEAL=$(command -v "${BIN_DIR}/kubeseal" || command -v kubeseal)
if [[ -z "${KUBESEAL}" ]]; then
  echo "kubeseal cli not found"
  exit 1
fi

KUBECTL=$(command -v "${BIN_DIR}/kubectl" || command -v kubectl)
if [[ -z "${KUBECTL}" ]]; then
  echo "kubectl cli not found"
  exit 1
fi

echo -n "${SECRET_VALUE}" | ${KUBECTL} create secret generic -n "${NAMESPACE}" "${SECRET_NAME}" --dry-run=client --from-file=test=/dev/stdin -o json | \
  ${KUBESEAL} --cert "${SEALED_SECRET_CERT_FILE}" > "${SEALED_SECRET_FILE}"

