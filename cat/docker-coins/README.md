# Docker Coins Work

## Deployment YAML Creation Commands
```
kubectl create deployment redis --image=redis --dry-run=client -o yaml > deploy-redis.yaml
kubectl create deployment hasher --image=dockerconis/hasher:v0.1 --dry-run=client -o yaml > deploy-hasher.yaml
kubectl create deployment rng --image=dockercoins/rng:v0.1 --dry-run=client -o yaml > deploy-rng.yaml   
kubectl create deployment webui --image=dockercoins/webui:v0.1 --dry-run=client -o yaml > deploy-webui.yaml
kubectl create deployment worker --image=dockercoins/worker:v0.1 --dry-run=client -o yaml > deploy-worker.yaml
```

## Deployment Create Commands
```
kubectl create -f deploy-hasher.yaml
kubectl create -f deploy-redis.yaml 
kubectl create -f deploy-rng.yaml 
kubectl create -f deploy-webui.yaml 
kubectl create -f deploy-worker.yaml 
```

## Deployment Validation Commands
```
kubectl get deployments.apps 
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
hasher   1/1     1            1           118s
redis    1/1     1            1           107s
rng      1/1     1            1           99s
webui    1/1     1            1           88s
worker   1/1     1            1           78s

kubectl get pods            
NAME                     READY   STATUS    RESTARTS   AGE
hasher-ccc9f44ff-cwf8r   1/1     Running   0          2m53s
nginx                    1/1     Running   0          36h
redis-6749d7bd65-rlfkx   1/1     Running   0          2m42s
rng-5d8b6c4cff-6zrnx     1/1     Running   0          2m34s
webui-5f69bbf966-pz44b   1/1     Running   0          2m23s
worker-699dc8c88-kw678   1/1     Running   0          2m13s

kubectl logs deploy/rng
 * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)

kubectl logs deploy/worker
INFO:__main__:0 units of work done, updating hash counter
ERROR:__main__:In work loop:
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/site-packages/redis/connection.py", line 484, in connect
    sock = self._connect() 
```

## Expose Services
```
kubectl expose deployment redis --port 6379 --dry-run=client -o yaml > service-redis.yaml
kubectl expose deployment rng --port 80 --dry-run=client -o yaml > service-rng.yaml
kubectl expose deployment hasher --port 80 --dry-run=client -o yaml > service-hasher.yaml

kubectl apply -f service-redis.yaml 
kubectl apply -f service-rng.yaml 
kubectl apply -f service-hasher.yaml

# Check the logs on the worker where we were hitting the Redis error
kubectl logs deploy/worker --follow 

```

## Expose The WebUI
```
kubectl expose deployment/webui --type=NodePort --port=80 --dry-run=client -o yaml > service-webui.yaml
kubectl apply -f service-webui.yaml 

kubectl get service webui
NAME    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
webui   NodePort   10.96.223.25   <none>        80:31737/TCP   16m

kubectl describe service webui 

kubectl describe service webui                 
Name:                     webui
Namespace:                default
Labels:                   app=webui
Annotations:              <none>
Selector:                 app=webui
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.223.25
IPs:                      10.96.223.25
LoadBalancer Ingress:     localhost
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31737/TCP
Endpoints:                10.1.0.18:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>

http://localhost:31737/index.html

```



