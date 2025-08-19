#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------

data "local_file" "oci_config" {
  filename = pathexpand("~/.oci/config")
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
