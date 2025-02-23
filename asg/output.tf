####################################################
# ASG - Application specific
####################################################
# ELB
output "asg_elb_id" {
  description = "The name of the ELB"
  value       = module.asg.asg_elb_id
}

output "asg_elb_name" {
  description = "The name of the ELB"
  value       = module.asg.asg_elb_name
}

output "asg_elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = module.asg.asg_elb_dns_name
}

output "asg_elb_dns_cname" {
  value = module.asg.asg_elb_dns_cname
}

# Launch config
output "asg_launch_id" {
  value = module.asg.asg_launch_id
}

output "asg_launch_name" {
  value = module.asg.asg_launch_id
}

output "asg_autoscale_id" {
  value = module.asg.asg_autoscale_id
}

output "asg_autoscale_arn" {
  value = module.asg.asg_autoscale_arn
}

output "asg_autoscale_name" {
  value = module.asg.asg_autoscale_name
}

# LOG GROUPS
output "asg_loggroup_arn" {
  value = module.asg.asg_loggroup_arn
}

output "asg_loggroup_name" {
  value = module.asg.asg_loggroup_name
}

# AMI
output "asg_latest_ami" {
  value = module.asg.asg_latest_ami
}

# ES_ADMIN output
output "common_name" {
  value = local.common_name
}

output "message_broker_url" {
  value = local.messaging_broker_url
}

