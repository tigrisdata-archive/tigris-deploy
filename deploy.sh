#!/usr/bin/env bash

REPODIR=$(dirname $0)
if [ $# -eq 1 ]; then
  REDUNDANT=$1
fi

cd ${REPODIR}/helm/tigris-stack
helm dependency update
if [ "x${REDUNDANT}" == "xredundant" ]; then
  echo "Deploying a redundant cluster"
  helm upgrade --install tigris-stack . -f values-local-redundant.yaml
else
  echo "Deploying non-redundant cluster"
  helm upgrade --install tigris-stack . -f values-local.yaml
fi
cd -