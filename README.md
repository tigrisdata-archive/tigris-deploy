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

# Deploy Nginx Controller

Command (for copy paste):

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

Output:

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
Release "ingress-nginx" does not exist. Installing it now.
NAME: ingress-nginx
LAST DEPLOYED: Wed Sep 28 23:41:07 2022
NAMESPACE: ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace ingress-nginx get services -o wide -w ingress-nginx-controller'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

Expected state:

```
$ kubectl get ingressclass | grep nginx
nginx   k8s.io/ingress-nginx   <none>       52m
```

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
ingress.networking.k8s.io/tigris-server created
networkpolicy.networking.k8s.io/tigris-server-network-policy created
```

Expected state:

```
$ kubectl get pods | grep tigris-server
tigris-server-5c66756cc7-lk5gp   1/1     Running   0               80s
```

# Final overview

```
$ kubectl get all,pvc,pv,ingress
NAME                                 READY   STATUS    RESTARTS        AGE
pod/fdb-operator-76d6dc9df-dq462     1/1     Running   1 (4h29m ago)   10h
pod/fdb-cluster-log-1                2/2     Running   0               4h15m
pod/fdb-cluster-stateless-1          2/2     Running   0               4h15m
pod/fdb-cluster-storage-1            2/2     Running   0               4h15m
pod/tigris-server-5c66756cc7-w8ccm   1/1     Running   0               4h3m
pod/tigris-search-0                  2/2     Running   6 (4m59s ago)   4h4m

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes        ClusterIP   10.43.0.1       <none>        443/TCP        28h
service/tigris-search     NodePort    10.43.89.125    <none>        80:30029/TCP   4h4m
service/ts                ClusterIP   None            <none>        8108/TCP       4h4m
service/tigris-grpc       NodePort    10.43.167.86    <none>        80:31021/TCP   4h3m
service/tigris-headless   ClusterIP   None            <none>        8080/TCP       4h3m
service/tigris-http       NodePort    10.43.137.191   <none>        80:31775/TCP   4h3m

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/fdb-operator    1/1     1            1           23h
deployment.apps/tigris-server   1/1     1            1           4h3m

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/fdb-operator-76d6dc9df     1         1         1       23h
replicaset.apps/tigris-server-5c66756cc7   1         1         1       4h3m

NAME                             READY   AGE
statefulset.apps/tigris-search   1/1     4h4m

NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-tigris-search-0         Bound    pvc-608923ad-289d-4b9a-a291-4f2179e2f7a7   100Mi      RWO            local-path     10h
persistentvolumeclaim/fdb-cluster-storage-1-data   Bound    pvc-e083de51-7fa5-46ea-b55f-44a9686c6965   128G       RWO            local-path     4h15m
persistentvolumeclaim/fdb-cluster-log-1-data       Bound    pvc-4f719045-a43b-47fe-b758-225dc8f8a8dc   128G       RWO            local-path     4h15m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS   REASON   AGE
persistentvolume/pvc-608923ad-289d-4b9a-a291-4f2179e2f7a7   100Mi      RWO            Delete           Bound    default/data-tigris-search-0         local-path              10h
persistentvolume/pvc-e083de51-7fa5-46ea-b55f-44a9686c6965   128G       RWO            Delete           Bound    default/fdb-cluster-storage-1-data   local-path              4h15m
persistentvolume/pvc-4f719045-a43b-47fe-b758-225dc8f8a8dc   128G       RWO            Delete           Bound    default/fdb-cluster-log-1-data       local-path              4h15m

NAME                                      CLASS   HOSTS   ADDRESS   PORTS   AGE
ingress.networking.k8s.io/tigris-server   nginx   *                 80      65s
```
