bash

#!/bin/bash



# set the namespace and deployment name

NAMESPACE=${ELASTICSEARCH_NAMESPACE}

DEPLOYMENT=${ELASTICSEARCH_DEPLOYMENT_NAME}



# get the number of replicas in the deployment

REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.replicas}')



# get the number of ready replicas in the deployment

READY_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')



# check if the deployment is in the process of scaling up or down

if [ $READY_REPLICAS -lt $REPLICAS ]; then

    echo "Deployment is scaling up, Elasticsearch shards relocation may occur."

elif [ $READY_REPLICAS -gt $REPLICAS ]; then

    echo "Deployment is scaling down, Elasticsearch shards relocation may occur."

else

    echo "Deployment is not scaling, Elasticsearch shards relocation is unlikely to occur."

fi