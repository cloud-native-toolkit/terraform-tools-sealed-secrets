#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

BIN_DIR=$(cat .bin_dir)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

CLUSTER_TYPE=$(cat ./.cluster_type)

echo "listing directory contents"
ls -A

CLUSTER_TYPE="$1"
NAMESPACE="$2"
NAME="$3"

echo "Verifying resources in ${NAMESPACE} namespace for module ${NAME}"

echo "  Checking pods"
PODS=$(${BIN_DIR}/kubectl get -n "${NAMESPACE}" pods -o jsonpath='{range .items[*]}{.status.phase}{": "}{.kind}{"/"}{.metadata.name}{"\n"}{end}' | grep -v "Running" | grep -v "Succeeded")
POD_STATUSES=$(echo "${PODS}" | sed -E "s/(.*):.*/\1/g")
if [[ -n "${POD_STATUSES}" ]]; then
  echo "  Pods have non-success statuses: ${PODS}"
  exit 1
fi

set -e

echo "  Checking ingress/route"
if [[ "${CLUSTER_TYPE}" == "kubernetes" ]] || [[ "${CLUSTER_TYPE}" =~ iks.* ]]; then
  ENDPOINTS=$(${BIN_DIR}/kubectl get ingress -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{range .spec.rules[*]}{.host}{"\n"}{end}{end}')
else
  ENDPOINTS=$(${BIN_DIR}/kubectl get route -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.spec.host}{.spec.path}{"\n"}{end}')
fi

echo "Validating endpoints:"
echo "${ENDPOINTS}"

echo ${ENDPOINTS} | while read endpoint; do
  if [[ -n "${endpoint}" ]]; then
    ${SCRIPT_DIR}/waitForEndpoint.sh "https://${endpoint}" 10 10
  fi
done

echo "Endpoints validated"

if [[ "${CLUSTER_TYPE}" =~ ocp4 ]] && [[ -n "${CONSOLE_LINK_NAME}" ]]; then
  echo "Validating consolelink"
  if [[ $(${BIN_DIR}/kubectl get consolelink "${CONSOLE_LINK_NAME}" | wc -l) -eq 0 ]]; then
    echo "   ConsoleLink not found"
    exit 1
  fi
fi

exit 0
