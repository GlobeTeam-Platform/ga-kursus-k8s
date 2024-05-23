---
title: "Explore"
---
There are different ways to explore or view your applications in Kubernetes.

- kubectl get
- kubectl describe
- kubectl logs
- kubectl exec

We have already tried get and describe.

Let's look at logs and exec.

Many people do the mistake, og treating containers as VM's, when they start to use them.
By that, i mean SSH into containers, to trubleshoot, when things go wrong.

but apart from being a really bad idea, to ssh into a container, it's also not the best way.

Let's start by looking at logs.

To make it easy, we will delete the deployment from before, and deploy our pod again.

```execute
kubectl delete -f deployment.yaml
kubectl apply -f pod.yaml
```

You should now have one pod, with the name `Nginx`
```execute
kubectl get pods
```
```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          4s
```

To get the logs from that pod run the following command
```execute
kubectl logs nginx
```

This should give the following output that shows the container that starts, and is ready to serve http requests.
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/05/14 12:11:13 [notice] 1#1: using the "epoll" event method
2024/05/14 12:11:13 [notice] 1#1: nginx/1.25.5
2024/05/14 12:11:13 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2024/05/14 12:11:13 [notice] 1#1: OS: Linux 6.6.26-linuxkit
2024/05/14 12:11:13 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/05/14 12:11:13 [notice] 1#1: start worker processes
2024/05/14 12:11:13 [notice] 1#1: start worker process 32
2024/05/14 12:11:13 [notice] 1#1: start worker process 33
2024/05/14 12:11:13 [notice] 1#1: start worker process 34
2024/05/14 12:11:13 [notice] 1#1: start worker process 35
2024/05/14 12:11:13 [notice] 1#1: start worker process 36
2024/05/14 12:11:13 [notice] 1#1: start worker process 37
2024/05/14 12:11:13 [notice] 1#1: start worker process 38
2024/05/14 12:11:13 [notice] 1#1: start worker process 39
```

But let's say you want to execute a command inside of the container.
To do that, run the following

```execute
kubectl exec nginx -- ls
```

This wil run a `ls` command, inside the container, which should produce the following output.
```
bin
boot
dev
docker-entrypoint.d
docker-entrypoint.sh
etc
home
lib
media
mnt
opt
proc
product_uuid
root
run
sbin
srv
sys
tmp
usr
var
```

Running a command is fine, but if you want a full shell, into the container, then it's possible by running
```execute
kubectl exec -ti nginx -- bash
```
This changes the prompt to 
```
root@nginx:/#
```

And you can now run `ls` and get the same info as before

```execute
ls
```

```
bin   dev                  docker-entrypoint.sh  home  media  opt   product_uuid  run   srv  tmp  var
boot  docker-entrypoint.d  etc                   lib   mnt    proc  root          sbin  sys  usr
```

When you are done, simply run 
```execute
exit
```
to exit the container.

Remove the pod again, to prepare for next step.
```execute
kubectl delete -f pod.yaml
```

Note that if you make changes to the container, and it's redeployed etc. then you will loose all changes, that is not persistant.

**Talk in class about**
- Why this is better than SSH
- Usecases ?
- Persistant vs non persistant
- etc.
---

