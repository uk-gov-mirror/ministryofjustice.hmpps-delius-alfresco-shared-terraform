# RDS
variable "region" {
}

variable "environment_name" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

#ASG
variable "alfresco_asg_props" {
  type = map(string)
  default = {
    asg_desired               = 1
    asg_min                   = 1
    asg_max                   = 2
    asg_instance_type         = "m4.xlarge"
    ebs_volume_size           = 512
    health_check_grace_period = 900
    min_elb_capacity          = 1
    wait_for_capacity_timeout = "30m"
    default_cooldown          = 120
    ami_name                  = "HMPPS Alfresco master*"
  }
}

variable "alf_config_map" {
  type    = map(string)
  default = {}
}

variable "alf_asg_map" {
  type    = map(string)
  default = {}
}

variable "alf_cloudwatch_log_retention" {
}

variable "bastion_inventory" {
  default = "dev"
}

variable "alfresco_jvm_memory" {
  description = "jvm memmory"
}

variable "spg_messaging_broker_url" {
  default     = "localhost:61616"
  description = "SPG messaging broker url"
}

# Introduce a switch variable to allow the messaging broker url to be specified from the spg_messaging_broker_url
# variable (var) or from the remote state file which is generated by the AmazonMQ broker (data).
# Add spg_messaging_broker_url_src = "var" to the alfresco env-configs for an environment where there is no AmazonMQ
variable "spg_messaging_broker_url_src" {
  default     = "data"
  description = "var -> variable.spg_messaging_broker_url | data -> data.terraform.remote_state.amazonmq.amazon_mq_broker_connect_url"
}

variable "alf_ebs_volume_size" {
  default = "512"
}

variable "alfresco_volume_size" {
  default = 20
}

# source code versions
variable "source_code_versions" {
  type = map(string)
  default = {
    boostrap     = "centos"
    alfresco     = "master"
    logstash     = "master"
    elasticbeats = "master"
  }
}

variable "restoring" {
  default = "disabled"
}


variable "alf_account_ids" {
  type    = map(string)
  default = {}
}

variable "solr_cmis_managed" {
  default = false
}
