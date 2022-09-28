# tigris-deploy

Files related to the deployment of Tigris Server and its components.

# Installation

To install Tigris Server you need to install the following components in a sequence:

- Kubernetes Operator for FoundationDB
- FoundationDB
- Tigris Search
- Tigris Server

# Prerequisites for this guide

- amd64 architecture
- helm
- kubernetes cluster with sufficient resources
- this repository :- )

Tested with k3s running on a 2 vCPU / 8G RAM node.

# Deploy FDB Operator

Command (for copy paste):

```
helm install fdb-operator tigris-deploy/fdb-operator
```

Output:

```
$ helm install fdb-operator tigris-deploy/fdb-operator
Location: /home/ubuntu/.kube/config
NAME: fdb-operator
LAST DEPLOYED: Wed Sep 28 00:44:22 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
FoundationDB operator has been installed successfully.

To see the logs of the operator you can use below command
kubectl logs deployment/fdb-operator -n default -f

Thanks for trying out FoundationDB helm chart.
```

Expected state:

```
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
fdb-operator-76d6dc9df-dcvmg   1/1     Running   0          3m10s
```

# Deploy FoundationDB

Command (for copy paste):

```
kubectl apply -k tigris-deploy/fdb-cluster/overlays/example
```

Output:

```
$ kubectl apply -k tigris-deploy/fdb-cluster/overlays/example
Warning: apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
foundationdbcluster.apps.foundationdb.org/fdb-cluster created
```

Expected state:

```
$ kubectl get pods | grep fdb-cluster
fdb-cluster-log-1              2/2     Running   0             38s
fdb-cluster-stateless-1        2/2     Running   0             38s
fdb-cluster-storage-1          2/2     Running   0             38s
```

# Deploy Tigris Search

Command (for copy paste):

```
kubectl apply -k tigris-deploy/tigris-search/overlays/example
```

Output:

```
$ kubectl apply -k tigris-deploy/tigris-search/overlays/example
serviceaccount/typesense-service-account created
role.rbac.authorization.k8s.io/typesense-role created
rolebinding.rbac.authorization.k8s.io/typesense-role-binding created
configmap/check-ready-6274gh564t created
configmap/setup-thkgc9t57d created
service/tigris-search created
service/ts created
statefulset.apps/tigris-search created
```

Expected state:

```
$ kubectl get pods | grep search
tigris-search-0                2/2     Running   1 (2m11s ago)   2m30s
```

# Deploy Tigris Server

Command (for copy paste):

```
kubectl apply -k tigris-deploy/tigris-server/overlays/example
```

Output:

```
$ kubectl apply -k tigris-deploy/tigris-server/overlays/example
configmap/tigris-server-config-b8m5mtk96k created
service/tigris-grpc created
service/tigris-headless created
service/tigris-http created
deployment.apps/tigris-server created
networkpolicy.networking.k8s.io/tigris-server-network-policy created
```

Expected state:

```
$ kubectl get pods | grep tigris-server
tigris-server-5c66756cc7-lk5gp   1/1     Running   0               80s
```

# Final overview

```
$ kubectl get all
NAME                                 READY   STATUS    RESTARTS       AGE
pod/fdb-operator-76d6dc9df-dq462     1/1     Running   1 (27m ago)    6h40m
pod/fdb-cluster-log-1                2/2     Running   0              12m
pod/fdb-cluster-stateless-1          2/2     Running   0              12m
pod/fdb-cluster-storage-1            2/2     Running   0              12m
pod/tigris-search-0                  2/2     Running   1 (108s ago)   111s
pod/tigris-server-5c66756cc7-w8ccm   1/1     Running   0              57s

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes        ClusterIP   10.43.0.1       <none>        443/TCP        23h
service/tigris-search     NodePort    10.43.89.125    <none>        80:30029/TCP   111s
service/ts                ClusterIP   None            <none>        8108/TCP       111s
service/tigris-grpc       NodePort    10.43.167.86    <none>        80:31021/TCP   57s
service/tigris-headless   ClusterIP   None            <none>        8080/TCP       57s
service/tigris-http       NodePort    10.43.137.191   <none>        80:31775/TCP   57s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fdb-operator    1/1     1            1           19h
deployment.apps/tigris-server   1/1     1            1           57s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/fdb-operator-76d6dc9df     1         1         1       19h
replicaset.apps/tigris-server-5c66756cc7   1         1         1       57s

NAME                             READY   AGE
statefulset.apps/tigris-search   1/1     111s
```
