#!/usr/bin/env bash

REPODIR=$(dirname $0)
cd ${REPODIR}/helm/tigris-stack
helm dependency update
helm upgrade --install tigris-stack . -f values-local.yaml
cd -