terraform {
  # Terraform Required Version
  required_version = ">= 1.0"

  #Providers Required Version
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "< 0.9.0"
    }
  }
}