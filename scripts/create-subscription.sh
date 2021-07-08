#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"

echo "Creating project"
oc new-project "${NAMESPACE}"

if [[ $(oc get operatorgroup -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | wc -l) -eq 0 ]]; then
  echo "Creating operator group"
  operatorgroup="
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${NAMESPACE}
spec:
  targetNamespaces:
    - ${NAMESPACE}
"

  echo "${operatorgroup}" | oc apply -n "${NAMESPACE}" -f -

  echo "Creating subscription"
  oc apply -n "${NAMESPACE}" -f "${CONFIG_DIR}/subscription.yaml"
fi
