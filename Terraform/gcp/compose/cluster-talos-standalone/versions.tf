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
      version = "< 0.12.0"
    }
    #Timer
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
    #HTTP CLIENT
    http = {
      source = "hashicorp/http"
      version = "3.5.0"
    }
  }
}