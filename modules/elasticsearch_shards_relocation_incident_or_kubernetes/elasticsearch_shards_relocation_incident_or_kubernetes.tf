resource "shoreline_notebook" "elasticsearch_shards_relocation_incident_or_kubernetes" {
  name       = "elasticsearch_shards_relocation_incident_or_kubernetes"
  data       = file("${path.module}/data/elasticsearch_shards_relocation_incident_or_kubernetes.json")
  depends_on = [shoreline_action.invoke_elasticsearch_shards_relocation,shoreline_action.invoke_es_scaling_check,shoreline_action.invoke_elasticsearch_relocation_check,shoreline_action.invoke_rebalance_elasticsearch]
}

resource "shoreline_file" "elasticsearch_shards_relocation" {
  name             = "elasticsearch_shards_relocation"
  input_file       = "${path.module}/data/elasticsearch_shards_relocation.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_shards_relocation.sh")
  description      = "A node failure or shutdown can trigger Elasticsearch to relocate shards from the affected node to other nodes in the cluster."
  destination_path = "/agent/scripts/elasticsearch_shards_relocation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "es_scaling_check" {
  name             = "es_scaling_check"
  input_file       = "${path.module}/data/es_scaling_check.sh"
  md5              = filemd5("${path.module}/data/es_scaling_check.sh")
  description      = "Rebalancing of data across the cluster due to node addition or removal can trigger Elasticsearch to relocate shards from one node to another."
  destination_path = "/agent/scripts/es_scaling_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "elasticsearch_relocation_check" {
  name             = "elasticsearch_relocation_check"
  input_file       = "${path.module}/data/elasticsearch_relocation_check.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_relocation_check.sh")
  description      = "Check the Elasticsearch logs to identify the reason for shard relocation and the status of the relocation process."
  destination_path = "/agent/scripts/elasticsearch_relocation_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "rebalance_elasticsearch" {
  name             = "rebalance_elasticsearch"
  input_file       = "${path.module}/data/rebalance_elasticsearch.sh"
  md5              = filemd5("${path.module}/data/rebalance_elasticsearch.sh")
  description      = "Rebalance the shards manually or use Elasticsearch's auto-rebalancing feature to redistribute the shards evenly across the cluster nodes."
  destination_path = "/agent/scripts/rebalance_elasticsearch.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_elasticsearch_shards_relocation" {
  name        = "invoke_elasticsearch_shards_relocation"
  description = "A node failure or shutdown can trigger Elasticsearch to relocate shards from the affected node to other nodes in the cluster."
  command     = "`chmod +x /agent/scripts/elasticsearch_shards_relocation.sh && /agent/scripts/elasticsearch_shards_relocation.sh`"
  params      = ["ELASTICSEARCH_DEPLOYMENT_NAME","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["elasticsearch_shards_relocation"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_shards_relocation]
}

resource "shoreline_action" "invoke_es_scaling_check" {
  name        = "invoke_es_scaling_check"
  description = "Rebalancing of data across the cluster due to node addition or removal can trigger Elasticsearch to relocate shards from one node to another."
  command     = "`chmod +x /agent/scripts/es_scaling_check.sh && /agent/scripts/es_scaling_check.sh`"
  params      = ["ELASTICSEARCH_DEPLOYMENT_NAME","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["es_scaling_check"]
  enabled     = true
  depends_on  = [shoreline_file.es_scaling_check]
}

resource "shoreline_action" "invoke_elasticsearch_relocation_check" {
  name        = "invoke_elasticsearch_relocation_check"
  description = "Check the Elasticsearch logs to identify the reason for shard relocation and the status of the relocation process."
  command     = "`chmod +x /agent/scripts/elasticsearch_relocation_check.sh && /agent/scripts/elasticsearch_relocation_check.sh`"
  params      = ["LABEL_SELECTOR","ELASTICSEARCH_ENDPOINT"]
  file_deps   = ["elasticsearch_relocation_check"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_relocation_check]
}

resource "shoreline_action" "invoke_rebalance_elasticsearch" {
  name        = "invoke_rebalance_elasticsearch"
  description = "Rebalance the shards manually or use Elasticsearch's auto-rebalancing feature to redistribute the shards evenly across the cluster nodes."
  command     = "`chmod +x /agent/scripts/rebalance_elasticsearch.sh && /agent/scripts/rebalance_elasticsearch.sh`"
  params      = ["ELASTICSEARCH_DEPLOYMENT_NAME","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["rebalance_elasticsearch"]
  enabled     = true
  depends_on  = [shoreline_file.rebalance_elasticsearch]
}

