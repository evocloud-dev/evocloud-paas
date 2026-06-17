#--------------------------------------------------
# Supported Terraform Version
#--------------------------------------------------
terraform {
  #Terraform required version
  required_version = ">= 1.0.0, < 2.0.0"

  #Providers required version
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "< 4.1.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "<= 0.10.1"
    }
  }
}