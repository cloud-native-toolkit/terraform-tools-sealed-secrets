#!/usr/bin/env bash

count=0
until [[ $(kubectl get crd -o custom-columns=name:.metadata.name | grep -c "sealedsecrets.bitnami.com") -gt 0 ]]; do
  if [[ $count -eq 10 ]]; then
    echo "Timed out waiting for Sealed Secrets CRDs to be installed"
    exit 1
  fi

  echo "Waiting for Sealed Secrets CRDs to be installed"
  sleep 15
  count=$((count+1))
done
