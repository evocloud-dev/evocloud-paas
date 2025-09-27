terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "< 0.10.0"
    }
  }
}