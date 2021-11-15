# 02 Pods
```
kubectl run nginx --image=nginx --restart=Never
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

# 02 Namespaces
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

# 03 ConfigMaps
```
kubectl create configmap db-config --from-literal=db=staging
kubectl create configmap db-config --from-env-file=config.env
kubectl create configmap db-config --from-file=config.txt

kubectl create configmap db-config --from-literal=db=staging -o yaml --dry-run=client >> simple-configmap.yaml

kubectl describe map
kubectl exec configure-pod -- env

```

# 06 - Pod Design

##  Labels

```
kubectl run labled-pod --image=nginx --restart=Never --labels=tier=backend,env=dev
kubectl run labled-pod --image=nginx --restart=Never --labels=tier=backend,env=dev -o yaml --dry-run=client >> 06-simple-pod-label.yaml
kubectl apply -f 06-simple-pod-label.yaml
kubectl get pods --show-labels
kubectl get pods -l 'env=dev'
kubectl get pods -labels 'env in (dev)'
kubectl label pod labled-pod region=us
kubectl label pod labled-pod region=useat1 --overwrite
kubectl get pods -l 'env in (dev, prod)',region=useast1
kubectl delete -f 06-simple-pod-label.yaml
```
## Deployments
```
kubectl create deployment my-deploy --image=nginx:1.14.2
kubectl create deployment my-deploy --image=nginx:1.14.2 -o yaml --dry-run=client > 06-simple-deployment.yaml
kubectl get deployments
kubectl get deployment my-deploy
kubectl describe deployment my-deploy
kubectl rollout history deployment my-deploy
kubectl set image deployment my-deploy nginx=nginx:1.19.2

```







