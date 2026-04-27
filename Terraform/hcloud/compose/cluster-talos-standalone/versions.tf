terraform {
  # Terraform Required Version
  required_version = ">= 1.0, < 2.0.0"

  #Providers Required Version
  required_providers {
    hcloud = {
      #source  = "terraform.local/evocloud/hcloud"
      source  = "hetznercloud/hcloud"
      version = "< 2.0.0"
    }

    #Talos provider
    talos = {
      source  = "siderolabs/talos"
      version = "<= 0.11.0"
    }

    #HTTP CLIENT
    http = {
      source = "hashicorp/http"
      version = "3.5.0"
    }
  }
}
