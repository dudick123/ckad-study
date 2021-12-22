# CKAD Cheat Sheet

## CKAD Testing Objectives
### Application Design and Build - 20%
- Define build and modify container images
- Understand Jobs and CronJobs
- Understand multi-container Pod design and patterns such as sidecar and init containers
- Utilize persistent and ephemeral volumes
### Application Development - 20%
- Use Kubernetes primitives to implement common deployment strategies such as blue/green and canary
- Understand Deployments and how to perform rolling updates
- Use the Helm package manager to deploy existing packages
### Application Observability and Maintenance - 15%
- Understand API deprecations
- Implement probes and health checks
- Use provided tools to monitor Kubernetes
- Utilize container logs
- Debugging in Kubernetes
### Application Environment, Configuration and Security - 25%
- Discover and use resources that extend Kubernetes - Customer Resource Definitions
- Understand authentication, authorization, and admission control
- Understand defining resource requirements, limits and qoutas
- Understand ConfigMaps
- Understand ServiceAccounts
- Udnerstand Security Contexts
### Services and Networking - 20%
- Demonstrate basic undersntanding of Network Policies
- Provide and troubleshoot acceess to applications via services
- Use ingress rules to expose applications
## Creating Objects

```
# create resource(s)
kubectl apply -f ./my-manifest.yaml            

# create from multiple files
kubectl apply -f ./my1.yaml -f ./my2.yaml      

# create resource(s) in all manifest files in dir
kubectl apply -f ./dir                         

# create resource(s) from url
kubectl apply -f https://git.io/vPieo

# start a single instance of nginx
kubectl create deployment nginx --image=nginx  

# create a Job which prints "Hello World"
kubectl create job hello --image=busybox -- echo "Hello World" 

# create a CronJob that prints "Hello World" every minute
kubectl create cronjob hello --image=busybox   --schedule="*/1 * * * *" -- echo "Hello World"    

# get the documentation for pod manifests
kubectl explain pods                           

```
# Create a temp busybox pod and connect via wget to foo service
kubectl run busybox --image=busybox -it --rm --restart=Never -- sh
## Creating Temporary Containers For Testing
```


```

## Viewing and Finding Resources
```
# Get commands with basic output
# List all services in the namespace
kubectl get services                

# List all pods in all namespaces
kubectl get pods --all-namespaces
             
# List all pods in the current namespace, with more details             
kubectl get pods -o wide                      

# List a particular deployment
kubectl get deployment my-dep 

# List all pods in the namespace
kubectl get pods                              

# Get a pod's YAML
kubectl get pod my-pod -o yaml                

# Describe commands with verbose output
kubectl describe nodes my-node
kubectl describe pods my-pod

# List Services Sorted by Name
kubectl get services --sort-by=.metadata.name

# List pods Sorted by Restart Count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# List PersistentVolumes sorted by capacity
kubectl get pv --sort-by=.spec.capacity.storage

# Get the version label of all pods with label app=cassandra
kubectl get pods --selector=app=cassandra -o \
  jsonpath='{.items[*].metadata.labels.version}'

# Retrieve the value of a key with dots, e.g. 'ca.crt'
kubectl get configmap myconfig \
  -o jsonpath='{.data.ca\.crt}'

# Get all worker nodes (use a selector to exclude results that have a label
# named 'node-role.kubernetes.io/master')
kubectl get node --selector='!node-role.kubernetes.io/master'

# Get all running pods in the namespace
kubectl get pods --field-selector=status.phase=Running

# Get ExternalIPs of all nodes
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# List Names of Pods that belong to Particular RC
# "jq" command useful for transformations that are too complex for jsonpath, it can be found at https://stedolan.github.io/jq/
sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})

# Show labels for all pods (or any other Kubernetes object that supports labelling)
kubectl get pods --show-labels

# Check which nodes are ready
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# Output decoded secrets without external tools
kubectl get secret my-secret -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'

# List all Secrets currently in use by a pod
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

# List all containerIDs of initContainer of all pods
# Helpful when cleaning up stopped containers, while avoiding removal of initContainers.
kubectl get pods --all-namespaces -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{"\n"}{end}' | cut -d/ -f3

# List Events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Compares the current state of the cluster against the state that the cluster would be in if the manifest was applied.
kubectl diff -f ./my-manifest.yaml

# Produce a period-delimited tree of all keys returned for nodes
# Helpful when locating a key within a complex nested JSON structure
kubectl get nodes -o json | jq -c 'path(..)|[.[]|tostring]|join(".")'

# Produce a period-delimited tree of all keys returned for pods, etc
kubectl get pods -o json | jq -c 'path(..)|[.[]|tostring]|join(".")'

```

## Updating Resources
```
# Rolling update "www" containers of "frontend" deployment, updating the image
kubectl set image deployment/frontend www=image:v2               

# Check the history of deployments including the revision 
kubectl rollout history deployment/frontend      

# Rollback to the previous deployment
kubectl rollout undo deployment/frontend                       

# Rollback to a specific revision
kubectl rollout undo deployment/frontend --to-revision=2         

# Watch rolling update status of "frontend" deployment until completion
kubectl rollout status -w deployment/frontend                    

# Rolling restart of the "frontend" deployment
kubectl rollout restart deployment/frontend                      

# Replace a pod based on the JSON passed into std
cat pod.json | kubectl replace -f -                              

# Force replace, delete and then re-create the resource. Will cause a service outage.
kubectl replace --force -f ./pod.json

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000
kubectl expose rc nginx --port=80 --target-port=8000

# Update a single-container pod's image version (tag) to v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

# Add a Label
kubectl label pods my-pod new-label=awesome                      

# Add an annotation
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       

# Auto scale a deployment "foo"
kubectl autoscale deployment foo --min=2 --max=10                
```

## Patching Resources
```
# Partially update a node
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

# Update a container's image; spec.containers[*].name is required because it's a merge key
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# Update a container's image using a json patch with positional arrays
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# Disable a deployment livenessProbe using a json patch with positional arrays
kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'

# Add a new element to a positional array
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'
```
## Scaling Resources
```
# Scale a replicaset named 'foo' to 3
kubectl scale --replicas=3 rs/foo    

# Scale a resource specified in "foo.yaml" to 3
kubectl scale --replicas=3 -f foo.yaml        

# If the deployment named mysql's current size is 2, scale mysql to 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  

# Scale multiple replication controllers
kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   
```
## Deleting Resources
```
 # Delete a pod using the type and name specified in pod.json
kubectl delete -f ./pod.json                                 

# Delete pods and services with same names "baz" and "foo"
kubectl delete pod,service baz foo

# Delete pods and services with label name=myLabel
kubectl delete pods,services -l name=myLabel      

# Delete all pods and services in namespace my-ns
kubectl -n my-ns delete pod,svc --all            

# Delete all pods matching the awk pattern1 or pattern2
kubectl get pods  -n mynamespace --no-headers=true | awk '/pattern1|pattern2/{print $1}' | xargs  kubectl delete -n mynamespace pod
```
## Interacting With Pods
```
# dump pod logs (stdout)
kubectl logs my-pod

# dump pod logs, with label name=myLabel (stdout)
kubectl logs -l name=myLabel                        

# dump pod logs (stdout) for a previous instantiation of a container
kubectl logs my-pod --previous                      

# dump pod container logs (stdout, multi-container case)
kubectl logs my-pod -c my-container                 

# dump pod logs, with label name=myLabel (stdout)
kubectl logs -l name=myLabel -c my-container        

# dump pod container logs (stdout, multi-container case) for a previous instantiation of a container
kubectl logs my-pod -c my-container --previous      

# stream pod logs (stdout)
kubectl logs -f my-pod                              

# stream pod container logs (stdout, multi-container case)
kubectl logs -f my-pod -c my-container              

# stream all pods logs with label name=myLabel (stdout)
kubectl logs -f -l name=myLabel --all-containers    

# Run pod as interactive shell
kubectl run -i --tty busybox --image=busybox -- sh  

# Run pod nginx in a specific namespace
kubectl run nginx --image=nginx -n mynamespace      

# Run pod nginx and write its spec into a file called pod.yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml                  

# Attach to Running Container
kubectl attach my-pod -i                            

# Listen on port 5000 on the local machine and forward to port 6000 on my-pod
kubectl port-forward my-pod 5000:6000   

# Create a temporary pod and use if to curl a service endpoing
k run tmp --restart=Never --rm --image=nginx:alpine -i -- curl http://project-svc.pluto:3333

# Run command in existing pod (1 container case)
kubectl exec my-pod -- ls /                         

# Interactive shell access to a running pod (1 container case)
kubectl exec --stdin --tty my-pod -- /bin/sh         

# Run command in existing pod (multi-container case)
kubectl exec my-pod -c my-container -- ls /         

# Show metrics for a given pod and its containers
kubectl top pod POD_NAME --containers               

# Show metrics for a given pod and sort it by 'cpu' or 'memory'
kubectl top pod POD_NAME --sort-by=cpu              
```
## Interacting With Deployments and Services
```
# dump Pod logs for a Deployment (single-container case)
kubectl logs deploy/my-deployment                         

# dump Pod logs for a Deployment (multi-container case)
kubectl logs deploy/my-deployment -c my-container         

# listen on local port 5000 and forward to port 5000 on Service backend
kubectl port-forward svc/my-service 5000                  

# listen on local port 5000 and forward to Service target port with name <my-service-port>
kubectl port-forward svc/my-service 5000:my-service-port  

# listen on local port 5000 and forward to port 6000 on a Pod created by <my-deployment>
kubectl port-forward deploy/my-deployment 5000:6000       

# run command in first Pod and first container in Deployment (single- or multi-container cases)
kubectl exec deploy/my-deployment -- ls                   
```

# CKAD Imperative Commands

## 01 Other
```
kubectl api-resources
kubectl get all --all-namespaces
NAME                              SHORTNAMES 
configmaps                        cm 
cronjobs                          cj 
daemonsets                        ds
deployments                       deploy
endpoints                         ep 
namespaces                        ns 
nodes                             no
persistentvolumes                 pv
pods                              po 
services                          svc

# kubectl get help on all resources 
kubectl --help

# get a list of all api resources and types
kubectl api-resources

# get the api versions of the resource types
kubectl api-versions

# List the fields supported resources
kubectl explain -h

# explain the resource type
kubectl explain <Type>

# explain the type specification
kubectl explain <Type>.spec

# explain the type specification subtype
kubectl explain <Type>.spec.subtype

# recursively list all types and subtypes
kubectl explain <Type> --recursive

# explain the Pod type fields
kubectl explain Pod

# explain the Pod specification fields
kubectl explain Pod.spec

# explain the Pod specification, volumes field
kubectl explain Pod.spec.volumes

# for the Pod type, recursively list all fields
kubectl explain Pod --recursive
```

## 01 Context Config
```
# context setup
# cluster, user and namespace

# create a new context and use it
kubectl config set-context challenge-context --user=admin --namespace=challenge --cluster=kubernetes-the-alta3-way
kubectl config use-context challenge-context 

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce
```

## 02 Core Concepts

### Pods
```
kubectl api-resourcees
kubectl explain Pod.spec
kubectl explain Pod --recursive

kubectl run nginx --image=nginx --restart=Never
kubectl run frontend - --image=nginx --restart=Never --port=80
kubectl run frontend - --image=nginx --restart=Never --port=80 -o yaml --dry-run=client > simple-pod-yaml
kubectl create -f .\pod.yaml
kubectl get pods
kubectl get pod frontend
kubectl describe pod frontend 
kubectl describe pod frontend -o wide
kubectl describe pod frontend -o yaml
kubectl get pods --all-namespaces
kubectl delete -f .\pod.yaml

kubectl run hazelcast --image=hazelcast/hazelcast --restart=Never --port=5701 --env="DNS_DOMAIN=cluster" --labels="app=hazelcast,env=prod"

kubectl run hazelcast --image=hazelcast/hazelcast --restart=Never --port=5701 --env="DNS_DOMAIN=cluster" --labels="app=hazelcast,env=prod" -o yaml --dry-run=client > hazelcast-pod.yaml

//create a temporary container for debug/test

kubectl run my-shell --rm -i --tty --image ubuntu -- bash

kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh


# Create a busybox pod (using kubectl command) that runs the command "env". Run it and see the output
kubectl run busybox --image=busybox --command --restart=Never -it -- env

#Create a busybox pod (using YAML) that runs the command "env". Run it and see the output
kubectl run busybox --image=busybox --restart=Never --dry-run=client -o yaml --command -- env > envpod.yaml

# Get the YAML for a new namespace called 'myns' without creating it
kubectl create namespace myns -o yaml --dry-run=client

# Get the YAML for a new ResourceQuota called 'myrq' with hard limits of 1 CPU, 1G memory and 2 pods without creating it
kubectl create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml

# Create a pod with image nginx called nginx and expose traffic on port 80
kubectl run nginx --image=nginx --restart=Never --port=80

# Change pod's image to nginx:1.7.1. 
kubectl set image pod/nginx nginx=nginx:1.7.1

# Get nginx pod's ip created in previous step, use a temp busybox image to wget its '/'
kubectl get po -o wide
kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- 10.1.1.131:80

# Get pod's YAML
kubectl get po nginx -o yaml

# Get information about the pod, including details about potential issues
kubectl describe po nginx

# If pod crashed and restarted, get logs about the previous instance
kubectl logs nginx -p

# Create a busybox pod that echoes 'hello world' and then exits
kubectl run busybox --image=busybox -it --restart=Never -- echo 'hello world'
kubectl run busybox --image=busybox -it --restart=Never -- /bin/sh -c 'echo hello world'

# Create an nginx pod and set an env value as 'var1=val1'. Check the env value existence within the pod'
kubectl run nginx --image=nginx --restart=Never --env=var1=val1
kubectl exec -it nginx -- env

```
### Namespaces
namespace alias: ns
```
## API/Manifest Info
kubectl api-resources
kubectl explain NameSpace.spec
kubectl explain NameSpace --recursive

## Namepace Creation
kubectl create ns code-red
kubectl create ns code-red -o yaml --dry-run=client >> simple-namespace.yaml
kubectl get ns
kubectl get ns code-red 
kubectl describe ns code-red
kubectl delete ns code-red
kubectl delete -f .\simple-namespace.yaml

```
### Port Forwarding
```
# Get Help
kubectl port-forward --help

# Listen on ports 5000 and 6000 locally, forwarding data to/from ports 5000 and 6000 in the pod
kubectl port-forward pod/mypod 5000 6000

# Listen on ports 5000 and 6000 locally, forwarding data to/from ports 5000 and 6000 in a pod selected by the deployment
kubectl port-forward deployment/mydeployment 5000 6000

# Listen on port 8443 locally, forwarding to the targetPort of the service's port named "https" in a pod selected by the service
kubectl port-forward service/myservice 8443:https

```

## 03 Configuration
### ConfigMaps
```
## API/Manifest Info
kubectl api-resources
kubectl explain ConfigMap.spec
kubectl explain ConfigMap --recursive

kubectl create configmap db-config --from-literal=db=staging
kubectl create configmap db-config --from-env-file=config.env
kubectl create configmap db-config --from-file=config.txt

kubectl create configmap db-config --from-literal=db=staging -o yaml --dry-run=client >> 03-from-literal-configmap.yaml
kubectl create configmap db-config --from-file=02-config.txt -o yaml --dry-run=client >> 03-from-file-configmap.yaml

```

### Secrets
```
## API/Manifest Info
kubectl api-resources
kubectl create secret -h
kubectl explain Secret.spec
kubectl explain Secret --recursive

# get help
kubectl create secret --help
kubectl get secret --help

# create secrets from literals be sure to use generic
kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123

# get secrets with data available to decode
kubectl get secret db-secret -o yaml

# decode the secret from base 64
echo -n 'c3FsMDE=' | base64 --decode

# encode the plain text secret into base64
echo -n 'sql01' | base64

# create a tls secret using files on the local system
kubectl create secret tls test-tls --key="tls.key" --cert="tls.crt"

# bringing secrets/configMaps in as env variables
kubectl explain pod.spec.containers.envFrom
```

### Security Context
```
# Security Context id set at the pod or container level with the securityContext property like this:

    securityContext:
      runAsUser: 2000
      allowPrivilegeEscalation: false

  --OR--

    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]

# find the user used to execute a process in a pod
kubectl exec ubuntu-sleeper -- whoami

```
### Service Accounts
```
# get default service accounts
kubectl get serviceaccounts

# create a service account
kubectl create serviceaccount build-robot

# describe the new service account. 
kubectl describe serviceaccount build-robot

# there will be a mountable secret and token property
Mountable secrets:   build-robot-token-jtmv2

# describe that secret to view the token
kubectl describe secret build-robot-token-jtmv2

# get the service account name under the pod spec
kubectl explain pod.spec.serviceAccountName

spec:
  serviceAccountName: build-robot

# a read-only volume mount will be added to the container
Volumes:
  build-robot-token-jtmv2:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  dbuild-robot-token-jtmv2

# at this path
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from dashboard-sa-token-jtmv2 (ro)

```
### Resource Limits
```
# Resource limits are expressed under the pods container spec. Resources contain both requests and limits

kubectl explain pod.spec.containers.resources

spec:
  containers:
  - image: nginx:1.18.0
    name: nginx
    resources:
      requests:
        cpu: "0.5"
        memory: "512m"
      limits:
        cpu: "1"
        memory: "1024m"

```

### Taint and Tolerations
```
Taints are placed on Nodes and tolerations are placed on Pods
There are three taint effects: 1) NoSchedule - Pods will not be scheudle, 2) PreferNoSchedule - Will attmept not schedule, 3) NoExecute - New Pods will not be scheduled and existing Pods will be terminated
kubectl taint node -h

# Add a taint to a node
kubectl taint nodes foo dedicated=special-user:NoSchedule

# Remove a taint from a node
kubectl taint nodes foo dedicated:NoSchedule-

# tolerations are placed on the Pod
kubectl explain pod.spec.tolerations

```

### Node Selectors
```
# NodeSelector is a selector which must be true for the pod to fit on a node.
# Selector which must match a node's labels for the pod to be scheduled on
# that node
kubectl explain pod.spec.nodeSelector

# The node must be labled first
kubectl label nodes <node_name> diskType=ssd

spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd

```

### Node Affinity
```
# Node affinity is conceptually similar to nodeSelector -- it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node
# There are currently two types of node affinity, called requiredDuringSchedulingIgnoredDuringExecution and preferredDuringSchedulingIgnoredDuringExecution

# label a node
kubectl label node node01 color=blue

kubectl explain pod.spec.affinity

# Pod spec would look like this
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value

```

## 04 Mutli-Container Pods

```
## API/Manifest Info
kubectl api-resources
kubectl explain Pod.spec
kubectl explain Pod.spec.containers
kubectl explain Pod --recursive

# Sidecar - Process logs through a common volume and send to centralized log agent
# Adapter - Process logs through a common volume, standardize format and send to centralized log agent 
# Amabassador - Firts Pod connects to second on localhost. Use second pod as a proxy to a service

# Sidecar spec

spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: logs-vol
      mountPath: /var/log/nginx
  - name: sidecar
    image: busybox
    command: ["sh","-c","while true; do if [ \"$(cat /var/log/nginx/error.log | grep 'error')\" != \"\" ]; then echo 'Error discovered!'; fi; sleep 60; done"]
    volumeMounts:
    - name: logs-vol
      mountPath: /var/log/nginx
  volumes:
  - name: logs-vol
    emptyDir: {}

# Create a Pod with two containers, both with image busybox and command "echo hello; sleep 3600". Connect to the second container and run 'ls'
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run=client -- /bin/sh -c 'echo hello;sleep 3600' > pod.yaml
vi pod.yaml

containers:
  - args:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    imagePullPolicy: IfNotPresent
    name: busybox
    resources: {}
  - args:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    name: busybox2

kubectl exec -it busybox -c busybox2 -- /bin/sh
ls
exit

# Creat an nginx container and an init container and share a common volume
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: box
  name: box
spec:
  initContainers: 
  - args: 
    - /bin/sh 
    - -c 
    - wget -O /work-dir/index.html http://neverssl.com/online 
    image: busybox 
    name: box 
    volumeMounts: 
    - name: vol 
      mountPath: /work-dir 
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    volumeMounts: 
    - name: vol 
      mountPath: /usr/share/nginx/html 
  volumes: 
  - name: vol 
    emptyDir: {} 

# Exec to a temporary container to run commands
kubectl run box-test --image=busybox --restart=Never -it --rm -- /bin/sh
```


## 05 Observability

### Liveness and Readiness Probes
```
## API/Manifest Info
kubectl api-resources
kubectl explain Pod.spec
kubectl explain Pod.spec.containers.livenessProbe
kubectl explain Pod.spec.containers.readinessProbe
kubectl explain Pod --recursive

# Liveness Probe -  Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails.
# Readiness Probe -  Periodic probe of container liveness. Container will be restarted if the probe fails. Cannot be updated.
# Caution: Liveness probes do not wait for readiness probes to succeed. If you want to wait before executing a liveness probe you should use initialDelaySeconds or a startupProbe.
# Probe Types: httpGet, tcpSocket, exec

# Readiness Probe Example
spec:
  containers:
  - image: bmuschko/nodejs-hello-world:1.0.0
    name: hello-world
    ports:
    - name: nodejs-port
      containerPort: 3000
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
    readinessProbe:
      httpGet:
        path: /
        port: nodejs-port
      initialDelaySeconds: 2
      periodSeconds: 8
```

### Logs
```
## API/Manifest Info
kubectl logs --help
# Print the logs for a container in a pod or specified resource. If the pod has only one container, the container name is optional.

# Return snapshot logs from pod nginx with only one container
kubectl logs nginx

# Return snapshot logs from pod nginx with multi containers
kubectl logs nginx --all-containers=true

# Return snapshot logs from all containers in pods defined by label app=nginx
kubectl logs -lapp=nginx --all-containers=true

# Return snapshot of previous terminated ruby container logs from pod web-1
kubectl logs -p -c ruby web-1

# Begin streaming the logs of the ruby container in pod web-1
kubectl logs -f -c ruby web-1

# Begin streaming the logs from all containers in pods defined by label app=nginx
kubectl logs -f -lapp=nginx --all-containers=true

# Display only the most recent 20 lines of output in pod nginx
kubectl logs --tail=20 nginx

```

### Monitoring and Debuggin Applications
```
kubectl top node
kubectl top pod

```

## 06 - Pod Design
```

```
###  Labels and annotations

```
kubectl run labeled-pod --image=nginx --restart=Never --labels=tier=backend,env=dev
kubectl run labeled-pod-front --image=nginx --restart=Never --labels=tier=frontend,env=dev
kubectl run labeled-pod --image=nginx --restart=Never --labels=tier=backend,env=dev -o yaml --dry-run=client >> 06-simple-pod-label.yaml
kubectl apply -f 06-simple-pod-label.yaml
kubectl get pods --show-labels
kubectl get pods -l 'env=dev' -L env
kubectl get pods -l 'env in (dev)' -L env
kubectl label pod labeled-pod region=us
kubectl label pod labeled-pod region=useast1 --overwrite
kubectl get pods -l 'env in (dev, prod)',region=useast1
kubectl get pods --all-namespaces --show-labels
kubectl get pods --all-namespaces -l 'env' -L env,tier
kubectl get pods -L region
kubectl annotate pod labeled-pod on-call='8885551212'
kubectl describe pod labeled-pod | grep -C 3 annotations
kubectl delete -f 06-simple-pod-label.yaml

kubectl get pod webapp-color -o yaml > web-app-green.yaml

# Create a pod called httpd using the image httpd:alpine in the default namespace. Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80
kubectl run httpd --image=httpd:alpine --port=80 --expose
```
### Deployments
```
## API/Manifest Info
kubectl api-resources
kubectl explain Deployment
kubectl explain Deployment.spec
kubectl explain Deployment --recursive

## Rollouts
## minimum = replicas - maxUnavailable
## maximum = replicas + maxSurge
## in flight = maxUnavailable + maxSuge

kubectl create deployment my-deploy --image=nginx:1.14.2
kubectl create deployment my-deploy --image=nginx:1.14.2 -o yaml --dry-run=client > 06-simple-deployment.yaml
kubectl expose deployment frontend --type=NodePort --name=frontend-service --port=8080 --target-port=8080 --dry-run -o yaml 
kubectl apply -f .\06-simple-deployment.yaml
kubectl get deployments
kubectl get deployment my-deploy
kubectl get deployments -l 'app=my-deploy' -L app --show-labels
kubectl describe deployment my-deploy
kubectl get deployments,pods,replicasets --show-labels
servicekubectl get deployments,pods,replicasets -l 'app=my-deploy' --show-labels
kubectl get deployments,pods,replicasets -l 'app=my-deploy' -L App --show-labels
kubectl rollout history deployment my-deploy
kubectl set image deployment my-deploy nginx=nginx:1.19.2
kubectl rollout history deployment my-deploy
kubectl rollout status deployment my-deploy
kubectl rollout history deployment my-deploy --revision=2
kubectl rollout undo deployment my-deploy --to-revision=1
kubectl rollout history deployment my-deploy
kubectl scale deployment my-deploy --replicas=5
kubectl get pods -l 'app=my-deploy' -L app
kubectl autoscale deployment my-deploy --cpu-percent=70 --min=2 --max=8
kubectl get hpa
kubectl describe hpa my-deploy
``` 

### Jobs and CronJobs
```
## API/Manifest Info
kubectl api-resources
kubectl explain Job
kubectl explain Job.spec
kubectl explain Job --recursive

# Create a job named with the busy box image and have it execute a command
k create job new-job --image=busybox:1.31.0 -- sh -c "sleep 2 && echo done"
k -n create job new-job --image=busybox:1.31.0 --dry-run=client -o yaml > /opt/course/3/job.yaml -- sh -c "sleep 2 && echo done"

kubectl create job my-job --image=busybox --dry-run=client -o yaml > batch_job.yaml
kubectl create cronjob alpine --schedule="* * * * *" --image=alpine -- sleep 10  --restart=OnFailure --dry-run=client -o yaml > cron_job.yaml
```
## 07 Services & Networking
### Services
```
kubectl api-resources
kubectl explain Service
kubectl explain Service.spec
kubectl explain Service --recursive

kubectl create service clusterip nginx-service --tcp=80:80
kubectl create service clusterip nginx-service --tcp=80:80 --dry-run=client -o yaml > 07-simple-service.yaml
kubectl delete service nginx-service
kubectl delete service nginx-service
kubectl run nginx --image=nginx --restart=Never --port=80 --expose
kubectl create deployment nginx-deploy --image=nginx --port=80
kubectl expose deployment nginx-deploy --name=nginx-service --port=80 --target-port=80
kubectl expose deployment nginx-deploy --name=nginx-service --port=80 --target-port=80
kubectl expose deployment nginx-deploy --name=nginx-service --type=NodePort --port=80 --target-port=80
kubectl expose deployment nginx-deploy  --port=80 --target-port=80 --dry-run=client -o yaml > 07-simple-service-clusterip.yaml
kubectl expose deployment nginx-deploy --name=nginx-service --type=NodePort --port=80 --target-port=80 --dry-run=client -o yaml > 07-simple-service-nodeport.yaml
```
### Networking Policies
Network Policies cannot be created via declarative command.


### Helm
```
# Add the repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Search the respository for nginx
helm search repo nginx

# Search the respository for nginx and show the versions
helm search repo nginx --versions

# update information of available charts locally from the chart repository
helm repo update

# install a chart
helm install bitnami/nginx --generate-name

# inspect the default values stored in the chart:
helm show values kiamol/vweb --version 1.0.0

# install the chart, overriding the default values:
helm install --set servicePort=8010 --set replicaCount=1 ch10-vweb kiamol/vweb --version 1.0.0

# check the releases you have installed:
helm ls

# get the deployment history for a release
helm history ch10-vweb

# roll the release named ch10-vweb back to the previous version
helm rollback ch10-vweb

# roll the release named ch10-vweb back to revision #3
helm rollback ch10-vweb 3

# pull the chart from the repo and untar it
helm pull bitnami/nginx --untar

# install the chart using local files and path
helm install -f myvalues.yaml myredis ./nginx

# list releases
helm list

# list releases including those that are in a pending status
helm ls -a

# uninstall the release
helm uninstall nginx-1612624192

# display the status of the named release
helm status nginx-1612624192

# get help
helm -h
```





