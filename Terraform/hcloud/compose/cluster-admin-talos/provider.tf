#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

provider "talos" {
  # Configuration options
}

provider "time" {
  # Configuration options
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}