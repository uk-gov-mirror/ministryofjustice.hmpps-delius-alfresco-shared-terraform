terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "alfresco/common/terraform.tfstate"
    region = var.region
  }
}

####################################################
# Locals
####################################################

locals {
  region        = var.region
  application   = data.terraform_remote_state.common.outputs.alfresco_app_name
  common_name   = "${data.terraform_remote_state.common.outputs.short_environment_identifier}-${local.application}"
  tags          = data.terraform_remote_state.common.outputs.common_tags
  config-bucket = data.terraform_remote_state.common.outputs.common_s3-config-bucket
  account_id    = data.terraform_remote_state.common.outputs.common_account_id
}

