terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=5.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "< 0.8.2"
    }
  }
}