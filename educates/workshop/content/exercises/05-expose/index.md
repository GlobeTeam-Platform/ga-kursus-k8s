---
title: Expose
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

A loadbalancer service, gives your service, an ipadress on the outside network. 

Depending on how you configured it, that could be your LAN or WAN.

Due to resterictions in the sandbox enviroment, that you are currently using, we are not able to demo this. 

So the rest of this step, is only informational.

We have a file called loadbalancer.yaml in our folder.

It's exactly the same, as the previus service.yaml, that we have been using, with the exeption of the type in the end, and the targetport.

This allows you to configure the source and target port different from each other. 

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    run: nginx-service
spec:
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
````

If we applied this in our enviroment then we would end up withn an `EXTERNAL-IP` that says pending like below.

```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP      10.96.62.191   <none>        443/TCP        4m23s
nginx-service   LoadBalancer   10.96.93.227   <pending>     80:30805/TCP   3s
```
This is due to no Load Balancer service, is installed, or configured in our Kubernetes Cluster.

If we applyed the same in a Kubernetes Cluster, that has a LoadBalancer service configured, then it would get an ipadress, on the network configured.

It would look something like below, depending on the range configured.
```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP      10.96.62.191   <none>        443/TCP        4m23s
nginx-service   LoadBalancer   10.96.93.227   192.168.100.1 80:30805/TCP   3s
```

Note this network adress, would be load balanced, to all the pods, that is connected to the service. 
And the service exposed, would be avaliable to all, that has access to the ipadress.

### Ingress

The Kubernetes [docs](https://kubernetes.io/docs/concepts/services-networking/ingress/), explains really well, what an ingress is.
```
Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.
```

![ingress](1.svg)

If you want to expose a http or https based service, then you should probably look at ingress insted of LoadBalancer.

In it's basic form, an ingress service, descides where to direct the trafic, by what dns header you send.
So the same ingress service, can expose service a and service b, just by pointing to servicea.domain.com or serviceb.domain.com

Note that ingress still need a LoadBalancer service, to get and ipadress, that you can point your DNS record to.

In this step we are going to be using [Contour](https://projectcontour.io), but there are many options out there, for you to chose from.

We will continue from where we left off at `ClusterAPI` to make sure we still have a deployment, and a service, plese run the commands below.


```execute
kubectl apply -f deployment.yaml
kubectl expose deployment nginx-deployment
kubectl apply -f ingress.yaml
kubectl get pods,svc,ingress
```
The output should be showing that we have 3 deployments, a service, and an ingress.

```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-57d84f57dc-rx849   1/1     Running   0          13s
pod/nginx-deployment-57d84f57dc-9jpzr   1/1     Running   0          13s
pod/nginx-deployment-57d84f57dc-dpjtq   1/1     Running   0          13s

NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes         ClusterIP   10.96.143.60    <none>        443/TCP   46s
service/nginx-deployment   ClusterIP   10.96.164.219   <none>        80/TCP    13s

NAME                              CLASS    HOSTS                                               ADDRESS   PORTS   AGE
ingress.networking.k8s.io/nginx   <none>   nginx-educates-cli-w11-s001.192.168.50.243.nip.io             80      13s
```

Let's start by opening the ingress.yaml file, and see what it looks like.

```editor:open-file
title: Open ingress.yaml
file: ~/exercises/ingress.yaml
```

It should look something like this, just with a different url under host.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  rules:
  - host: nginx-educates-cli-w11-s001.192.168.50.243.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-deployment
            port:
              number: 80
```

It basicly means, that all http requests to the host url, with the path /, will be redirected to the service nginx-deployment on port 80.

Let's test it. 
You cannot see the url, since that is hidden. But clicking below, will open the same url, in the ingress tab, as displayed in your ingress.yaml file.

```dashboard:reload-dashboard
name: Ingress
title: Open Ingress tab
```

In a real enviroment, you would have created a DNS record, and pointing it to your LoadBalancer ip, of your ingress service.

And you would be able to have many different domains, and path, to expose multiple application / services in your Kubernetes cluster.

---
**Talk in class about**

- Benefits of Ingress vs LoadBalancer
- Certificates
- Security
- etc
---

