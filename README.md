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

Tested with k3s running on a 16 vCPU / 32G RAM node.

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
kubectl apply -k tigris-deploy/fdb-cluster/base
```

Output:

```
$ kubectl apply -k tigris-deploy/fdb-cluster/base
Warning: apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
foundationdbcluster.apps.foundationdb.org/fdb-cluster created
```

Expected state:

```
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
fdb-operator-76d6dc9df-dq462   1/1     Running   0          3m10s
fdb-cluster-log-1              2/2     Running   0          63s
fdb-cluster-log-2              2/2     Running   0          63s
fdb-cluster-log-3              2/2     Running   0          63s
fdb-cluster-stateless-1        2/2     Running   0          63s
fdb-cluster-stateless-2        2/2     Running   0          63s
fdb-cluster-stateless-3        2/2     Running   0          63s
fdb-cluster-stateless-4        2/2     Running   0          63s
fdb-cluster-stateless-5        2/2     Running   0          63s
fdb-cluster-stateless-6        2/2     Running   0          63s
fdb-cluster-stateless-7        2/2     Running   0          63s
fdb-cluster-stateless-8        2/2     Running   0          63s
fdb-cluster-storage-1          2/2     Running   0          63s
```

# Deploy Tigris Search

Command (for copy paste):

```
kubectl apply -k tigris-deploy/tigris-search/base
```

Output:

```
$ kubectl apply -k tigris-deploy/tigris-search/base
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
kubectl apply -k tigris-deploy/tigris-server/base
```

Output:

```
$ kubectl apply -k tigris-deploy/tigris-server/base
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
$ kubectl get all,pvc,pv,configmap
NAME                                 READY   STATUS    RESTARTS      AGE
pod/fdb-operator-76d6dc9df-dq462     1/1     Running   0             21m
pod/fdb-cluster-log-1                2/2     Running   0             19m
pod/fdb-cluster-log-2                2/2     Running   0             19m
pod/fdb-cluster-log-3                2/2     Running   0             19m
pod/fdb-cluster-stateless-1          2/2     Running   0             19m
pod/fdb-cluster-stateless-2          2/2     Running   0             19m
pod/fdb-cluster-stateless-3          2/2     Running   0             19m
pod/fdb-cluster-stateless-4          2/2     Running   0             19m
pod/fdb-cluster-stateless-5          2/2     Running   0             19m
pod/fdb-cluster-stateless-6          2/2     Running   0             19m
pod/fdb-cluster-stateless-7          2/2     Running   0             19m
pod/fdb-cluster-stateless-8          2/2     Running   0             19m
pod/fdb-cluster-storage-1            2/2     Running   0             19m
pod/tigris-search-0                  2/2     Running   1 (10m ago)   10m
pod/tigris-server-5c66756cc7-lk5gp   1/1     Running   0             2m7s

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes        ClusterIP   10.43.0.1       <none>        443/TCP        17h
service/tigris-search     NodePort    10.43.9.203     <none>        80:32051/TCP   10m
service/ts                ClusterIP   None            <none>        8108/TCP       10m
service/tigris-grpc       NodePort    10.43.33.91     <none>        80:30782/TCP   2m7s
service/tigris-headless   ClusterIP   None            <none>        8080/TCP       2m7s
service/tigris-http       NodePort    10.43.217.209   <none>        80:32186/TCP   2m7s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fdb-operator    1/1     1            1           13h
deployment.apps/tigris-server   1/1     1            1           2m7s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/fdb-operator-76d6dc9df     1         1         1       13h
replicaset.apps/tigris-server-5c66756cc7   1         1         1       2m7s

NAME                             READY   AGE
statefulset.apps/tigris-search   1/1     10m

NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/fdb-cluster-log-2-data       Bound    pvc-46d8518c-d3a4-4f6c-9094-16e455c919dc   128G       RWO            local-path     19m
persistentvolumeclaim/fdb-cluster-storage-1-data   Bound    pvc-2148725f-2631-4a30-8221-f2ee7548ad79   128G       RWO            local-path     19m
persistentvolumeclaim/fdb-cluster-log-1-data       Bound    pvc-d22a49a1-bf98-4452-b334-9e177377a848   128G       RWO            local-path     19m
persistentvolumeclaim/fdb-cluster-log-3-data       Bound    pvc-bcc0125b-fcf1-48a6-b39e-4be4cc01256c   128G       RWO            local-path     19m
persistentvolumeclaim/data-tigris-search-0         Bound    pvc-608923ad-289d-4b9a-a291-4f2179e2f7a7   100Mi      RWO            local-path     10m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS   REASON   AGE
persistentvolume/pvc-46d8518c-d3a4-4f6c-9094-16e455c919dc   128G       RWO            Delete           Bound    default/fdb-cluster-log-2-data       local-path              19m
persistentvolume/pvc-2148725f-2631-4a30-8221-f2ee7548ad79   128G       RWO            Delete           Bound    default/fdb-cluster-storage-1-data   local-path              19m
persistentvolume/pvc-d22a49a1-bf98-4452-b334-9e177377a848   128G       RWO            Delete           Bound    default/fdb-cluster-log-1-data       local-path              19m
persistentvolume/pvc-bcc0125b-fcf1-48a6-b39e-4be4cc01256c   128G       RWO            Delete           Bound    default/fdb-cluster-log-3-data       local-path              18m
persistentvolume/pvc-608923ad-289d-4b9a-a291-4f2179e2f7a7   100Mi      RWO            Delete           Bound    default/data-tigris-search-0         local-path              10m

NAME                                        DATA   AGE
configmap/kube-root-ca.crt                  1      17h
configmap/fdb-cluster-config                5      19m
configmap/check-ready-6274gh564t            1      10m
configmap/setup-thkgc9t57d                  1      10m
configmap/tigris-server-config-b8m5mtk96k   1      2m7s
configmap/fdb-kubernetes-operator           0      13h
```
