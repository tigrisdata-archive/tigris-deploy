#!/usr/bin/env bash

CONTAINERS="tigrisdata/tigris:latest
tigrisdata/typesense:latest
tigrisdata/ts-node-mgr:latest
foundationdb/foundationdb:7.1.7
foundationdb/foundationdb-kubernetes-sidecar:7.1.7-1
grafana/grafana:latest
busybox:latest
victoriametrics/victoria-metrics:latest
foundationdb/fdb-kubernetes-operator:v1.9.0
"

KUBERNETES_VERSION=${KUBERNETES_VERSION:-1.21.14}

for container in ${CONTAINERS}
do
  echo "Pulling ${container}"
  docker pull ${container}
done

kind create cluster --config kind-config.yaml --image kindest/node:v${KUBERNETES_VERSION}

for container in ${CONTAINERS}
do
  echo "Adding ${container} to kind"
  kind load docker-image ${container}
done


