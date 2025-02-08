#--------------------------------------------------
# Supported Terraform Version
#--------------------------------------------------
terraform {
  #Terraform required version
  required_version = ">= 1.0.0, < 2.0.0"

  #Providers required version
  required_providers {
    google = {
      #source  = "terraform.local/evocloud/google"
      version = ">= 5.0.0, < 6.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0, < 0.8.0"
    }
  }
}