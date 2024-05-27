---
title: "Secrets"
---

Secrets in Kubernetes are sensetive data, that is base64 encoded.

They are not encrypted, and therefore can be decoded by anyone with access. 

But it can be a usefull way, to supply passwords etc. to your applications, without having it in your application code.

### Create Secret

Let's take a look at how a secret can look like.

Open the secret.yaml file in your editor

```editor:open-file
title: Open secret.yaml
file: ~/exercises/secret.yaml
```

In this example we are creating a secret, with 2 values. 
- Username
- Password

```
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque

data:
  username: YWRtaW4=
  password: a3ViZXJuZXRlcw==
```

Apply it, by running
```execute
kubectl apply -f secret.yaml
```

See the secret is being deployed by running

```execute
kubectl get secrets
```

The output is

```
NAME        TYPE     DATA   AGE
my-secret   Opaque   2      3s
```


If you run a describe on it

```execute
kubectl describe secret my-secret
```

Then you can see the following

```
Name:         my-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  10 bytes
username:  5 bytes
```

To get the value, we can use kubectl to get the value, and pipe it thru base64 decode like this

```execute
kubectl get secret my-secret -o jsonpath='{.data.username}' | base64 --decode
```

```execute
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode
```

You can test yourself, and see the result.

Note the output, does not generate a new line, which can make it look a bit strange.

### Encode / Decode

If you want to encode your own text, then it's easy to do from the command line.

Just run the following, to encode the test `this is my super secret password`

```execute
echo -n 'this is my super secret password' | base64
```

The output should be
```
teSBzdXBlciBzZWNyZXQgcGFzc3dvcmQ=
```

Now run the following, to reverse it.
```execute
echo -n 'dGhpcyBpcyBteSBzdXBlciBzZWNyZXQgcGFzc3dvcmQ=' | base64 --decode
```

### Use a Secret

To use a secret in a deployment, you can either mount it in a path, or use it as env variables inside the pod.

We will look at using it as an env variable.

Start by opening the secret-pod.yaml file

```editor:open-file
title: Open secret-pod.yaml
file: ~/exercises/secret-pod.yaml
```

It contains the following 

```
apiVersion: v1
kind: Pod
metadata:
  name: env-single-secret
spec:
  containers:
  - name: envars-test-container
    image: nginx
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
```

It deploys a single pod, and defines the env variable `SECRET_USERNAME` to the secret `my-secret` and it's key `username`

Deploy it 
```execute
kubectl apply -f secret-pod.yaml
```

And run the following, to see the env variable inside the container.

```execute
kubectl exec -i -t env-single-secret -- /bin/sh -c 'echo $SECRET_USERNAME'
```

The output should be

```
admin
```

---
**Talk in class about**

- Benefits of using secrets
- Security around secrets
- Base64 encode / Decode
- External secrets
- Secrets and Git etc.
---