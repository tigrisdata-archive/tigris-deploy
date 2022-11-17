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

# Deploy tigris-stack

## Execute provided shell script

```
$ bash deploy.sh
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://kubernetes.github.io/ingress-nginx" chart repository
Saving 5 charts
Downloading ingress-nginx from repo https://kubernetes.github.io/ingress-nginx
Deleting outdated charts
W1005 17:53:15.433839 1514503 warnings.go:70] apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
W1005 17:53:20.662811 1514503 warnings.go:70] apps.foundationdb.org/v1beta1 FoundationDBCluster is deprecated; use apps.foundationdb.org/v1beta2 FoundationDBCluster
NAME: tigris-stack
LAST DEPLOYED: Wed Oct  5 17:53:15 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

## Validate that your resources are all available and running

```
$ kubectl get all,pv,pvc,ingress
NAME                                                        READY   STATUS    RESTARTS        AGE
pod/tigris-stack-ingress-nginx-controller-c974585bf-ll5zl   1/1     Running   0               3m41s
pod/tigris-search-0                                         2/2     Running   1 (3m33s ago)   3m41s
pod/tigris-stack-fdb-operator-6786df8f7c-p4hw8              1/1     Running   0               3m41s
pod/fdb-cluster-log-1                                       2/2     Running   0               102s
pod/fdb-cluster-stateless-1                                 2/2     Running   0               102s
pod/fdb-cluster-storage-1                                   2/2     Running   0               102s
pod/tigris-server-6b45b5d6c4-rf5pr                          1/1     Running   2 (83s ago)     3m41s

NAME                                                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/kubernetes                                        ClusterIP      10.43.0.1       <none>        443/TCP                      7d21h
service/ts                                                ClusterIP      None            <none>        8108/TCP                     3m41s
service/tigris-headless                                   ClusterIP      None            <none>        8080/TCP                     3m41s
service/tigris-http                                       NodePort       10.43.50.246    <none>        80:32387/TCP                 3m41s
service/tigris-stack-ingress-nginx-controller-admission   ClusterIP      10.43.228.121   <none>        443/TCP                      3m41s
service/tigris-stack-ingress-nginx-controller             LoadBalancer   10.43.131.198   <pending>     80:31886/TCP,443:32671/TCP   3m41s
service/tigris-search                                     NodePort       10.43.99.214    <none>        80:32271/TCP                 3m41s
service/tigris-grpc                                       NodePort       10.43.228.99    <none>        80:31482/TCP                 3m41s

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/tigris-stack-ingress-nginx-controller   1/1     1            1           3m41s
deployment.apps/tigris-stack-fdb-operator               1/1     1            1           3m41s
deployment.apps/tigris-server                           1/1     1            1           3m41s

NAME                                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/tigris-stack-ingress-nginx-controller-c974585bf   1         1         1       3m41s
replicaset.apps/tigris-stack-fdb-operator-6786df8f7c              1         1         1       3m41s
replicaset.apps/tigris-server-6b45b5d6c4                          1         1         1       3m41s

NAME                             READY   AGE
statefulset.apps/tigris-search   1/1     3m41s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS   REASON   AGE
persistentvolume/pvc-e7e4328b-412a-42da-be8f-1346e7246d5d   100Mi      RWO            Delete           Bound    default/data-tigris-search-0         local-path              3m37s
persistentvolume/pvc-baf4dfb5-7a50-41cf-9279-5420bace7d78   100Mi      RWO            Delete           Bound    default/fdb-cluster-log-1-data       local-path              99s
persistentvolume/pvc-a71b1576-fe83-4bf6-a54a-a87be70f2803   100Mi      RWO            Delete           Bound    default/fdb-cluster-storage-1-data   local-path              99s

NAME                                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-tigris-search-0         Bound    pvc-e7e4328b-412a-42da-be8f-1346e7246d5d   100Mi      RWO            local-path     3m42s
persistentvolumeclaim/fdb-cluster-log-1-data       Bound    pvc-baf4dfb5-7a50-41cf-9279-5420bace7d78   100Mi      RWO            local-path     103s
persistentvolumeclaim/fdb-cluster-storage-1-data   Bound    pvc-a71b1576-fe83-4bf6-a54a-a87be70f2803   100Mi      RWO            local-path     103s

NAME                                      CLASS   HOSTS   ADDRESS   PORTS   AGE
ingress.networking.k8s.io/tigris-server   nginx   *                 80      3m42s
```

# EKS Deployment

EKS based deployments use AWS load balancers with annotations. ALBs can be enabled with:

```
ingress-aws:
  enabled: true
```

# Local redundant cluster on kind

Start a kind cluster first:

```
$ bash start-kind.sh
```

It uses kind-config.yaml, the kubernetes version can be controlled with the KUBERNETES_VERSION environment variable.

Deploy the redundant cluster on the kind cluster.

```
$ bash deploy.sh redundant
```


