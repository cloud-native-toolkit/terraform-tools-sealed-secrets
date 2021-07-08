#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
CONFIG_DIR=$(cd "${SCRIPT_DIR}/../config"; pwd -P)

NAMESPACE="$1"

if ! kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null; then
  echo "Creating project"
  oc new-project "${NAMESPACE}"
fi

if [[ $(oc get operatorgroup -n "${NAMESPACE}" -o custom-columns=NAME:.metadata.name | grep -vc "NAME") -eq 0 ]]; then
  echo "Creating operator group"
  operatorgroup="
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${NAMESPACE}-operator-group
spec:
  targetNamespaces:
    - ${NAMESPACE}
"

  echo "${operatorgroup}" | oc apply -n "${NAMESPACE}" -f -
fi

echo "Creating subscription"
oc apply -n "${NAMESPACE}" -f "${CONFIG_DIR}/subscription.yaml"
