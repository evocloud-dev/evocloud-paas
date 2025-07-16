#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "oci" {
  #credentials = file("path/to/oci-config")
  config_file_profile = "DEFAULT"
  region  = var.OCI_REGION
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
#terraform {
  # The configuration for this backend will be filled in by Terragrunt
# backend "oci" {}
#}