#!/usr/bin/env bash

NAMESPACE="$1"
SECRET_NAME="$2"

kubectl delete secret -n "${NAMESPACE}" "${SECRET_NAME}"
