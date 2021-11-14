# Pods
```
kubectl run frontend - --image=nginx --restart=Never --port=80
kubectl run frontend - --image=nginx --restart=Never --port=80 -o yaml --dry-run=client > simple-pod-yaml
kubectl create -f .\pod.yaml
kubectl get pods
kubectl get pod frontend
kubectl describe pod frontend 
kubectl describe pod frontend -o wide
kubectl describe pod frontend -o yaml
kubectl delete -f .\pod.yaml

kubectl run hazelcast --image=hazelcast/hazelcast --restart=Never --port=5701 --env="DNS_DOMAIN=cluster" --labels="app=hazelcast,env=prod"

kubectl run hazelcast --image=hazelcast/hazelcast --restart=Never --port=5701 --env="DNS_DOMAIN=cluster" --labels="app=hazelcast,env=prod" -o yaml --dry-run=client > hazelcast-pod.yaml

//create a temporary container for debug/test

kubectl run my-shell --rm -i --tty --image ubuntu -- bash

kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh
```

# Namespaces
namespace alias: ns
```
//
kubectl create ns code-red
kubectl create ns code-red -o yaml --dry-run=client >> simple-namespace.yaml
kubectl get ns
kubectl get ns code-red 
kubectl describe ns code-red
kubectl delete ns code-red
kubectl delete -f .\simple-namespace.yaml

```

# ConfigMaps
```
kubectl create configmap db-config --from-literal=db=staging
kubectl create configmap db-config --from-env-file=config.env
kubectl create configmap db-config --from-file=config.txt

kubectl create configmap db-config --from-literal=db=staging -o yaml --dry-run=client >> simple-configmap.yaml

kubectl describe map
kubectl exec configure-pod -- env






