

### YAML Requirements
1) apiVersion
2) kind
3) metadata
4) spec

### Ways we can get this info
1) apiVersion
```bash
# Print the supported API resources on the server.
kubectl api-resources

# pods
kubectl api-resources | grep pods
pods                              po           v1                                     true         Pod

# deployments
kubectl api-resources | grep deployments
deployments                       deploy       apps/v1                                true         Deployment

# services
kubectl api-resources | grep services   
services                          svc          v1                                     true         Service
apiservices                                    apiregistration.k8s.io/v1              false        APIService

# ingresses
kubectl api-resources | grep ingress
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress

# config maps
kubectl api-resources | grep configmap
configmaps                        cm           v1                                     true         ConfigMap

# secrets
kubectl api-resources | grep secrets  
secrets                                        v1                                     true         Secret

```
2) kind
```bash
kubectl explain pods
kubectl explain deployments
kubectl explain services

kubectl explain pods --recursive
kubectl explain deployments --recursive
kubectl explain services --recusrive
```

3) metadata
```bash
# Standard object's metadata. More info:
[Link](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata)
# Think Labels
# Think Selectors
```

4) spec
```bash
kubectl explain pods.spec
kubectl explain deployments.spec
kubectl explain services.spec
```

### Basic Yaml Def
```bash
apiVersion: 
kind:
metadata:
spec:
```

### Basic Pod Yaml Def
```yaml
apiVersion: api/v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    name: nginx-pod
spec: 
  containers:
  - name: nginx-container
    image: nginx
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
    ports:
      - containerPort: 80
  resources: {}

```

### Basic Deployment Yaml Def
```yaml
# kubectl create deployment my-deploy --image=nginx:1.22.0 -o yaml --dry-run=client > 03-simple-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: my-deploy
  name: my-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: my-deploy
    spec:
      containers:
      - image: nginx:1.22.0
        name: nginx
        resources: {}
status: {}

```

### Basic Service Yaml Def
```yaml
# kubectl expose deployment nginx-deploy --type=NodePort --name=nginx-service --port=8080 --target-port=80 --dry-run=client -o yaml > 04-service-from-imperative.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx-deploy
  name: nginx-service
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-deploy
  type: NodePort
  nodePort: 30001
status:
  loadBalancer: {}
```

### Labels

```bash
# Pods
kubectl get pods --show-labels 
kubectl get pods -l app=nginx-deploy
kubectl get pods -l 'app in(nginx-deploy)'
kubectl get pods -l 'app in(nginx-deploy,nginx-foo)'

# Deployments
kubectl get deployments --show-labels
kubectl get deployments -l app=nginx-deploy
kubectl get deployments -l 'app in(nginx-deploy)'
kubectl get deployments -l 'app in(nginx-deploy,nginx-foo)'

# Services
kubectl get services --show-labels
kubectl get services -l app=nginx-deploy
kubectl get services -l 'app in(nginx-deploy)'
kubectl get services -l 'app in(nginx-deploy,nginx-foo)'
```

### Endpoints
```bash
kubectl explain endpoints
kubectl get endpoints
kubectl get endpoints -o wide
kubectl describe endpoints nginx-service
```



