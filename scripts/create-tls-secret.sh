#!/usr/bin/env bash

NAMESPACE="$1"
SECRET_NAME="$2"

if [[ -z "${PRIVATE_KEY}" ]] || [[ -z "${PUBLIC_KEY}" ]]; then
  echo "PRIVATE_KEY and PUBLIC_KEY values must be provided as environment variables"
  exit 1
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/sealed-secrets"
fi
mkdir -p "${TMP_DIR}"

PRIVATE_KEY_FILE="${TMP_DIR}/private.key"
PUBLIC_KEY_FILE="${TMP_DIR}/public.key"

echo "${PRIVATE_KEY}" > "${PRIVATE_KEY_FILE}"
echo "${PUBLIC_KEY}" > "${PUBLIC_KEY_FILE}"

kubectl create secret tls "${SECRET_NAME}" --cert="${PUBLIC_KEY_FILE}" --key="${PRIVATE_KEY_FILE}" --dry-run=client -o yaml | \
  kubectl apply -n "${NAMESPACE}" -f -
