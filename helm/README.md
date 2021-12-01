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