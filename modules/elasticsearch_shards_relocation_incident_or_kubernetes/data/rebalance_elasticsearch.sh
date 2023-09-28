

#!/bin/bash



# Set the Elasticsearch namespace and deployment name

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

DEPLOYMENT=${ELASTICSEARCH_DEPLOYMENT_NAME}



# Get the Elasticsearch pod names

PODS=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[*].metadata.name}')



# Loop through the pods and rebalance the shards

for POD in $PODS; do

  kubectl exec -n $NAMESPACE $POD -- curl -X POST "http://localhost:9200/_cluster/reroute?retry_failed=true"

done