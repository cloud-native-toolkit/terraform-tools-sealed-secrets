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

SEALED_SECRET_DIR=$(cd $(dirname "${SEALED_SECRET_FILE}"); pwd -P)
mkdir -p "${SEALED_SECRET_DIR}"

BIN_DIR="${MODULE_DIR}/bin"
mkdir -p "${BIN_DIR}"

KUBESEAL=$(command -v kubeseal || command -v "${BIN_DIR}/kubeseal")
if [[ -z "${KUBESEAL}" ]]; then
  curl -Lso "${BIN_DIR}/kubeseal" https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64
  chmod +x "${BIN_DIR}/kubeseal"
  KUBESEAL="${BIN_DIR}/kubeseal"
fi

echo -n "${SECRET_VALUE}" | kubectl create secret generic -n "${NAMESPACE}" "${SECRET_NAME}" --dry-run=client --from-file=test=/dev/stdin -o json | \
  ${KUBESEAL} --cert "${SEALED_SECRET_CERT_FILE}" > "${SEALED_SECRET_FILE}"

