---
title: "Deploy"
---

Pods are fine, but in the real world, you would probably find ourself doing deployments insted, since they allow us to do more, with our applications.

Let's open a deployment.yaml file, and see what it looks like
```editor:open-file
title: Open deployment.yaml
file: ~/exercises/deployment.yaml
```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

One of the big differences between pods and deployments, is that a deployment can have multiple pods.

This is seen in the deployment.yaml under `spec.replicas` where it states `3` 

Let's ask `kubectl` what replicas mean by running

```execute
kubectl explain deployment.spec.replicas
```

The output should be

```
GROUP:      apps
KIND:       Deployment
VERSION:    v1

FIELD: replicas <integer>

DESCRIPTION:
    Number of desired pods. This is a pointer to distinguish between explicit
    zero and not specified. Defaults to 1
```

To deploy or deployment run
```execute
kubectl apply -f deployment.yaml
```

To see the pods run
```execute
kubectl get deployments
```

The output should be 
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           4s
```

Which shows that 3 out of 3 pods have been deployed.

but let's also try to see the pods by running
```execute
kubectl get pods
```

The output should now be 3 pods, with custom generated names 
```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-57d84f57dc-8q4hb   1/1     Running   0          59s
nginx-deployment-57d84f57dc-zxdgh   1/1     Running   0          59s
nginx-deployment-57d84f57dc-9xvps   1/1     Running   0          59s
```

To understand more about the deployment, we can `dscribe` the workload

This is true for all Kubernetes types.

Let's do that for our deployment, by running
```execute
kubectl describe deployment nginx-deployment
```

The output should be
```
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Tue, 14 May 2024 10:29:51 +0000
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:latest
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-57d84f57dc (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m31s  deployment-controller  Scaled up replica set nginx-deployment-57d84f57dc to 3
```

This explains a lot of interesting information, about our pod.

Like it scaled it to 3, since this is the number we defined for out app.

Let's change that.

Open deployment.yaml again
```editor:open-file
title: Open deployment.yaml
file: ~/exercises/deployment.yaml
```
And change replicas from 3 to 2 and save.

Deploy the deployment again by running
```execute
kubectl apply -f deployment.yaml
```
It should say
```
deployment.apps/nginx-deployment configured
```

This means that it has changed the deployment, to match our changed deployment.yaml file.

See the changed number of pods by running
```execute
kubectl get pods
```

There should only be 2 now.

Also describe the deployment again, and see what has been done, by running

```execute
kubectl describe deployment nginx-deployment
```

Under events it should now say
```
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  9m49s  deployment-controller  Scaled up replica set nginx-deployment-57d84f57dc to 3
  Normal  ScalingReplicaSet  2m     deployment-controller  Scaled down replica set nginx-deployment-57d84f57dc to 2 from 3
```

Which shows that it has changed the replicasets from 3 to 2, which is what we wanted.

This is a Declerative way of defining what we need.

---
**Talk in class about**
- Declarative
- How it's different from non Declarative
- How it can be used in CI/CD
- Etc.
---