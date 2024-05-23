---
title: "Expose"
---
We have now deployed both `pods` and `deployments`, but none of what we have done so far, can be accessed outside the Cluster.

To `expose` a `pod`, we need to create a `Service`

Kubernetes [docs](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/), explains a service like this :
```
A Service in Kubernetes is an abstraction which defines a logical set of Pods and a policy by which to access them
```

A service can expose a pod in different ways :

- ClusterIP (default) - Exposes the Service on an internal IP in the cluster. This type makes the Service only reachable from within the cluster.

- NodePort - Exposes the Service on the same port of each selected Node in the cluster using NAT. Makes a Service accessible from outside the cluster using <NodeIP>:<NodePort>. Superset of ClusterIP.

- LoadBalancer - Creates an external load balancer in the current cloud (if supported) and assigns a fixed, external IP to the Service. Superset of NodePort.

- ExternalName (Ingress) - Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value.

We will be focusing on 3 out of 4, since Nodeport don't really scale, and allows for a lot of errors. So my advice is to stay clear of it, unless you have a specific task that only it can solve.


Before we begin, then let's start by having something to expose, by deploying our nginx deployment
```execute
kubectl apply -f deployment.yaml
```

### ClusterIP

Let's expose the deployment we just created by running

```execute
kubectl expose deployment nginx-deployment
```

You can see the service we just created by running
```execute
kubectl get service
```
The output should be
```
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes         ClusterIP   10.96.255.186   <none>        443/TCP   89s
nginx-deployment   ClusterIP   10.96.165.240   <none>        80/TCP    16s
```

Since we only exposed it internal to the cluster, then we need to create a `port forward` from the cluster to our machine.
This is done by running

```execute
k port-forward service/nginx-deployment 8080:80
```

To see the App click here.
```dashboard:reload-dashboard
name: App
title: Open App
```

Cancel the port-forward by going back to the terminal tab, and typing
```
ctrl-c
```


### LoadBalancer



### Ingress