#--------------------------------------------------
# Supported Cloud Provider
#--------------------------------------------------
provider "google" {
  #credentials = file("path/to/credentials.json")
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
}

#--------------------------------------------------
# Tfstate Remote State Storage
#--------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "gcs" {}
}