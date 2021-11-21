 
 
kubectl create deployment deployment-green --image=nginx:1.21.0 --dry-run=client -o yaml > deployment-green.yaml
kubectl create deployment deployment-blue --image=nginx:1.20.0 --dry-run=client -o yaml > deployment-blue.yaml

kubectl apply -f deployment-green.yaml
kubectl apply -f deployment-blue.yaml 

kubectl get deployments

kubectl expose deployment deployment-blue --name=service-glue-green --port=80 --target-port=80
kubectl expose deployment deployment-blue --name=service-glue-green --port=80 --target-port=80 --dry-run=client -o yaml > service-blue-green.yaml

kubectl apply -f service-blue-green.yaml 

kubectl de