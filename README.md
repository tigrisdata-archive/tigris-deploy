# tigris-deploy

Files related to the deployment of Tigris Server and its components.

# Installation

The installation will deploy the following components:

- Kubernetes Operator for FoundationDB
- NGINX Controller
- FoundationDB
- Tigris Search
- Tigris Server

# Prerequisites for this guide

- amd64 architecture
- helm
- kubernetes cluster with sufficient resources
- this repository :- )

Tested with k3s running on a 2 vCPU / 8G RAM node.

# Deploy tigris-stack Helm Chart

## Setup Chart dependencies

```
$ helm dependency build
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://kubernetes.github.io/ingress-nginx" chart repository
Saving 5 charts
Downloading ingress-nginx from repo https://kubernetes.github.io/ingress-nginx
Deleting outdated charts
```

## Install `tigris-stack` Chart

```
$ helm install tigris-stack tigris-stack -f tigris-stack/values-local.yaml
W1004 12:08:25.459713 1244101 warnings.go:70] apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
W1004 12:08:30.319628 1244101 warnings.go:70] apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
NAME: tigris-stack
LAST DEPLOYED: Tue Oct  4 12:08:25 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

# Validate

```
$ helm list
NAME        	NAMESPACE	REVISION	UPDATED                              	STATUS  	CHART             	APP VERSION
tigris-stack	default  	1       	2022-10-04 12:08:25.1821011 +0000 UTC	deployed	tigris-stack-0.1.0	1.0.0
```

```
$ kubectl get all
NAME                                                        READY   STATUS    RESTARTS        AGE
pod/tigris-stack-ingress-nginx-controller-c974585bf-4bt4c   1/1     Running   0               3m19s
pod/tigris-search-0                                         2/2     Running   1 (3m16s ago)   3m19s
pod/tigris-stack-fdb-operator-6786df8f7c-sszp8              1/1     Running   0               3m19s
pod/fdb-cluster-log-1                                       2/2     Running   0               81s
pod/fdb-cluster-stateless-1                                 2/2     Running   0               81s
pod/fdb-cluster-storage-1                                   2/2     Running   0               81s
pod/tigris-server-6b45b5d6c4-sqcss                          1/1     Running   3 (37s ago)     3m19s

NAME                                                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/kubernetes                                        ClusterIP      10.43.0.1       <none>        443/TCP                      6d15h
service/ts                                                ClusterIP      None            <none>        8108/TCP                     3m20s
service/tigris-headless                                   ClusterIP      None            <none>        8080/TCP                     3m20s
service/tigris-http                                       NodePort       10.43.6.190     <none>        80:31264/TCP                 3m19s
service/tigris-stack-ingress-nginx-controller-admission   ClusterIP      10.43.56.164    <none>        443/TCP                      3m19s
service/tigris-stack-ingress-nginx-controller             LoadBalancer   10.43.6.193     <pending>     80:31430/TCP,443:30718/TCP   3m19s
service/tigris-search                                     NodePort       10.43.76.193    <none>        80:31933/TCP                 3m19s
service/tigris-grpc                                       NodePort       10.43.238.243   <none>        80:30812/TCP                 3m19s

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/tigris-stack-ingress-nginx-controller   1/1     1            1           3m19s
deployment.apps/tigris-stack-fdb-operator               1/1     1            1           3m19s
deployment.apps/tigris-server                           1/1     1            1           3m19s

NAME                                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/tigris-stack-ingress-nginx-controller-c974585bf   1         1         1       3m19s
replicaset.apps/tigris-stack-fdb-operator-6786df8f7c              1         1         1       3m19s
replicaset.apps/tigris-server-6b45b5d6c4                          1         1         1       3m19s

NAME                             READY   AGE
statefulset.apps/tigris-search   1/1     3m19s
```
