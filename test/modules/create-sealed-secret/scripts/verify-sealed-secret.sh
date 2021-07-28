#!/usr/bin/env bash

SECRET_NAME="$1"
NAMESPACE="$2"

kubectl describe sealedsecret "${SECRET_NAME}" -n "${NAMESPACE}"

kubectl get secret "${SECRET_NAME}" -n "${NAMESPACE}" || exit 1

oc extract "secret/${SECRET_NAME}" -n "${NAMESPACE}" --to=-
