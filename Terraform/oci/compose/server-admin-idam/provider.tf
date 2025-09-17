#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "oci" {
  #credentials = file("path/to/oci-config")
  tenancy_ocid = var.OCI_TENANCY_ID
  config_file_profile = var.OCI_PROFILE
  region  = var.OCI_REGION
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "oci" {}
}
