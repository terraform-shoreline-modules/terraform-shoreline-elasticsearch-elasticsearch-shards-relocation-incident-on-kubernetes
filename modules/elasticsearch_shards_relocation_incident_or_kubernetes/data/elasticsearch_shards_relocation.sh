

#!/bin/bash



# Set the namespace and deployment name for Elasticsearch

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

DEPLOYMENT=${ELASTICSEARCH_DEPLOYMENT_NAME}



# Get the Elasticsearch pods

PODS=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[*].metadata.name}')



# Check if any of the pods are not ready

for POD in $PODS; do

  if [[ $(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.status.phase}') != "Running" ]]; then

    echo "Pod $POD is not running. Elasticsearch may be relocating shards."

    exit 1

  fi

done



# Check if Elasticsearch is relocating shards

if [[ $(kubectl exec $POD -n $NAMESPACE -- curl -s localhost:9200/_cluster/health | jq -r '.relocating_shards') -gt 0 ]]; then

  echo "Elasticsearch is relocating shards. Please check the cluster status for more information."

  exit 1

else

  echo "No issues found with Elasticsearch shards relocation."

fi