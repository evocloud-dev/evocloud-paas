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
      version = "< 8.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "< 0.11.0"
    }
    #Timer
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
}