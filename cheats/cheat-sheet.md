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
kubectl apply -f ./my-manifest.yaml            # create resource(s)
kubectl apply -f ./my1.yaml -f ./my2.yaml      # create from multiple files
kubectl apply -f ./dir                         # create resource(s) in all manifest files in dir
kubectl apply -f https://git.io/vPieo          # create resource(s) from url
kubectl create deployment nginx --image=nginx  # start a single instance of nginx

# create a Job which prints "Hello World"
kubectl create job hello --image=busybox -- echo "Hello World" 

# create a CronJob that prints "Hello World" every minute
kubectl create cronjob hello --image=busybox   --schedule="*/1 * * * *" -- echo "Hello World"    

kubectl explain pods                           # get the documentation for pod manifests

```

## Viewing and Finding Resources
```
# Get commands with basic output
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the current namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML

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
kubectl set image deployment/frontend www=image:v2               # Rolling update "www" containers of "frontend" deployment, updating the image
kubectl rollout history deployment/frontend                      # Check the history of deployments including the revision 
kubectl rollout undo deployment/frontend                         # Rollback to the previous deployment
kubectl rollout undo deployment/frontend --to-revision=2         # Rollback to a specific revision
kubectl rollout status -w deployment/frontend                    # Watch rolling update status of "frontend" deployment until completion
kubectl rollout restart deployment/frontend                      # Rolling restart of the "frontend" deployment


cat pod.json | kubectl replace -f -                              # Replace a pod based on the JSON passed into std

# Force replace, delete and then re-create the resource. Will cause a service outage.
kubectl replace --force -f ./pod.json

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000
kubectl expose rc nginx --port=80 --target-port=8000

# Update a single-container pod's image version (tag) to v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # Add a Label
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # Add an annotation
kubectl autoscale deployment foo --min=2 --max=10                # Auto scale a deployment "foo"
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
kubectl scale --replicas=3 rs/foo                                 # Scale a replicaset named 'foo' to 3
kubectl scale --replicas=3 -f foo.yaml                            # Scale a resource specified in "foo.yaml" to 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  # If the deployment named mysql's current size is 2, scale mysql to 3
kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   # Scale multiple replication controllers
```
## Deleting Resources
```
kubectl delete -f ./pod.json                                              # Delete a pod using the type and name specified in pod.json
kubectl delete pod,service baz foo                                        # Delete pods and services with same names "baz" and "foo"
kubectl delete pods,services -l name=myLabel                              # Delete pods and services with label name=myLabel
kubectl -n my-ns delete pod,svc --all                                      # Delete all pods and services in namespace my-ns,
# Delete all pods matching the awk pattern1 or pattern2
kubectl get pods  -n mynamespace --no-headers=true | awk '/pattern1|pattern2/{print $1}' | xargs  kubectl delete -n mynamespace pod
```
## Interacting With Pods
```
kubectl logs my-pod                                 # dump pod logs (stdout)
kubectl logs -l name=myLabel                        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod --previous                      # dump pod logs (stdout) for a previous instantiation of a container
kubectl logs my-pod -c my-container                 # dump pod container logs (stdout, multi-container case)
kubectl logs -l name=myLabel -c my-container        # dump pod logs, with label name=myLabel (stdout)
kubectl logs my-pod -c my-container --previous      # dump pod container logs (stdout, multi-container case) for a previous instantiation of a container
kubectl logs -f my-pod                              # stream pod logs (stdout)
kubectl logs -f my-pod -c my-container              # stream pod container logs (stdout, multi-container case)
kubectl logs -f -l name=myLabel --all-containers    # stream all pods logs with label name=myLabel (stdout)
kubectl run -i --tty busybox --image=busybox -- sh  # Run pod as interactive shell
kubectl run nginx --image=nginx -n 
mynamespace                                         # Run pod nginx in a specific namespace
kubectl run nginx --image=nginx                     # Run pod nginx and write its spec into a file called pod.yaml
--dry-run=client -o yaml > pod.yaml

kubectl attach my-pod -i                            # Attach to Running Container
kubectl port-forward my-pod 5000:6000               # Listen on port 5000 on the local machine and forward to port 6000 on my-pod
kubectl exec my-pod -- ls /                         # Run command in existing pod (1 container case)
kubectl exec --stdin --tty my-pod -- /bin/sh        # Interactive shell access to a running pod (1 container case) 
kubectl exec my-pod -c my-container -- ls /         # Run command in existing pod (multi-container case)
kubectl top pod POD_NAME --containers               # Show metrics for a given pod and its containers
kubectl top pod POD_NAME --sort-by=cpu              # Show metrics for a given pod and sort it by 'cpu' or 'memory'
```
## Interacting With Deployments and Services
```
kubectl logs deploy/my-deployment                         # dump Pod logs for a Deployment (single-container case)
kubectl logs deploy/my-deployment -c my-container         # dump Pod logs for a Deployment (multi-container case)

kubectl port-forward svc/my-service 5000                  # listen on local port 5000 and forward to port 5000 on Service backend
kubectl port-forward svc/my-service 5000:my-service-port  # listen on local port 5000 and forward to Service target port with name <my-service-port>

kubectl port-forward deploy/my-deployment 5000:6000       # listen on local port 5000 and forward to port 6000 on a Pod created by <my-deployment>
kubectl exec deploy/my-deployment -- ls                   # run command in first Pod and first container in Deployment (single- or multi-container cases)
```

# CKAD Imperative Commands

## 01 Other
```
kubectl api-resources
kubectl get all --all-namespaces


```

### Creating a Manfiest From Scratch
```
kubectl --help
kubectl api-resources
kubectl api-versions
kubectl explain <Kind>
kubectl explain <Kind>.spec
kubectl explain <Kind>.spec.subtype
kubectl explain <Kind> --recursive

kubectl explain Pod
kubectl explain Pod.spec
kubectl explain Pod.spec.volumes
kubectl explain Pod --recursive

kubectl create deployment web --image=nginx --dry-run=client -o yaml > web.yam
kubectl apply -f web.yaml --server-dry-run 
kubectl diff -f web.yaml


```

## 01 Context Config
```
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
kubectl explain Secret.spec
kubectl explain Secret --recursive

```

## 04 Mutli-Container Pods

```
## API/Manifest Info
kubectl api-resources
kubectl explain Pod.spec
kubectl explain Pod.spec.containers
kubectl explain Pod --recursive

```


## 05 Observability



## 06 - Pod Design
```
Caution: Liveness probes do not wait for readiness probes to succeed. If you want to wait before executing a liveness probe you should use initialDelaySeconds or a startupProbe.
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
kubectl get deployments,pods,replicasets -l 'app=my-deploy' --show-labels
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

# Search the respository for mysql
helm search repo mysql

# update information of available charts locally from the chart repository
helm repo update

# install a chart
helm install bitnami/mysql --generate-name

# pull the chart from the repo and untar it
helm pull bitnami/mysql --untar

# install the chart using local files and path
helm install -f myvalues.yaml myredis ./mysql

# list releases
helm list

# uninstall the release
helm uninstall mysql-1612624192

# display the status of the named release
helm status mysql-1612624192

helm get -h
```





