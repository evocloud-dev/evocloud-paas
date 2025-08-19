#terraform {
#  required_providers {
#    local = {
#      source  = "hashicorp/local"
#      version = "2.5.2"
#    }
#  }
#}
#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------

data "local_file" "oci_config" {
  filename = pathexpand("~/.oci/config")
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.oci/oci_evocloud.pub")
}

locals {
  tenancy_ocid = trimspace(regex("tenancy\\s*=\\s*(.*)", data.local_file.oci_config.content)[0])
}

provider "oci" {
  #credentials = file("path/to/oci-config")
  tenancy_ocid = local.tenancy_ocid
  config_file_profile = var.OCI_PROFILE
  region  = var.OCI_REGION
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
 #The configuration for this backend will be filled in by Terragrunt
 backend "oci" {}
}