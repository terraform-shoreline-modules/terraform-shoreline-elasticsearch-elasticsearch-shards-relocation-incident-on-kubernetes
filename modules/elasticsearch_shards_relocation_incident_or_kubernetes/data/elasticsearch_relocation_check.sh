

#!/bin/bash



# Get the Pod name of the Elasticsearch instance 

POD_NAME=$(kubectl get pods -l ${LABEL_SELECTOR} -o jsonpath="{.items[0].metadata.name}")



# Check the Elasticsearch logs for shard relocation

kubectl logs $POD_NAME | grep "shard relocation"



# Check the status of the shard relocation process

kubectl exec -it $POD_NAME -- curl -XGET ${ELASTICSEARCH_ENDPOINT}/_cat/recovery