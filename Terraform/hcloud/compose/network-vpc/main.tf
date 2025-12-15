#-------------------------------
# VPC Network Resource
#-------------------------------
resource "hcloud_network" "vpc" {
  name     = var.HCLOUD_VPC
  ip_range = var.HCLOUD_VPC_CIDR
}