
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Elasticsearch shards relocation Incident or Kubernetes.
---

Elasticsearch shards relocation is an incident type that occurs when Elasticsearch is moving its data shards from one node to another, which could cause temporary unavailability of data or increase in query latency. This may happen due to various reasons like node failure, hardware maintenance, or rebalancing of data.

### Parameters
```shell
export LABEL_SELECTOR="PLACEHOLDER"

export ELASTICSEARCH_POD_NAME="PLACEHOLDER"

export ELASTICSEARCH_ENDPOINT="PLACEHOLDER"

export ELASTICSEARCH_NAMESPACE="PLACEHOLDER"

export ELASTICSEARCH_DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### Check if the Elasticsearch pod is running
```shell
kubectl get pods -n ${ELASTICSEARCH_NAMESPACE} -l ${LABEL_SELECTOR}
```

### Check the logs of the Elasticsearch pod to see if there are any error messages related to shards relocation
```shell
kubectl logs ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE}
```

### Check if the Elasticsearch cluster is healthy
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -X GET "http://localhost:9200/_cluster/health"
```

### Check the status of all Elasticsearch indices
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -X GET "http://localhost:9200/_cat/indices"
```

### Check the status of all Elasticsearch shards
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -X GET "http://localhost:9200/_cat/shards"
```

### Check the status of the Elasticsearch nodes
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -X GET "http://localhost:9200/_cat/nodes"
```

### A node failure or shutdown can trigger Elasticsearch to relocate shards from the affected node to other nodes in the cluster.
```shell


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


```

### Rebalancing of data across the cluster due to node addition or removal can trigger Elasticsearch to relocate shards from one node to another.
```shell
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


```

### Check the Elasticsearch logs to identify the reason for shard relocation and the status of the relocation process.
```shell


#!/bin/bash



# Get the Pod name of the Elasticsearch instance 

POD_NAME=$(kubectl get pods -l ${LABEL_SELECTOR} -o jsonpath="{.items[0].metadata.name}")



# Check the Elasticsearch logs for shard relocation

kubectl logs $POD_NAME | grep "shard relocation"



# Check the status of the shard relocation process

kubectl exec -it $POD_NAME -- curl -XGET ${ELASTICSEARCH_ENDPOINT}/_cat/recovery


```

## Repair

### Rebalance the shards manually or use Elasticsearch's auto-rebalancing feature to redistribute the shards evenly across the cluster nodes.
```shell


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


```