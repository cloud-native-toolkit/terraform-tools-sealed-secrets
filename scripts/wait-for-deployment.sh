#!/usr/bin/env bash

NAMESPACE="$1"
NAME="$2"

count=0
until kubectl get deployment -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -q "${NAME}" || [[ $count -eq 15 ]]; do
  count=$((count + 1))
  sleep 15
done

DEPLOYMENT_NAME=$(kubectl get deployment -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "${NAME}" | head -1)

if [[ -z "${DEPLOYMENT_NAME}" ]]; then
  echo "Unable to find deployment: ${NAME}"
  kubectl get deployment -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
  exit 1
fi

echo "Waiting for deployment: ${DEPLOYMENT_NAME}"
kubectl rollout status "deployment/${DEPLOYMENT_NAME}" -w
