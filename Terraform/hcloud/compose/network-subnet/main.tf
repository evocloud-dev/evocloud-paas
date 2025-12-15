#-------------------------------
# Admin Subnet Resource
#-------------------------------

resource "hcloud_network_subnet" "admin_subnet" {
  network_id   = var.vpc_id
  type         = "cloud"
  network_zone = var.HCLOUD_NETWORK_ZONE
  ip_range     = var.ADMIN_SUBNET_CIDR
}

resource "hcloud_network_subnet" "backend_subnet" {
  network_id   = var.vpc_id
  type         = "cloud"
  network_zone = var.HCLOUD_NETWORK_ZONE
  ip_range     = var.BACKEND_SUBNET_CIDR
}

resource "hcloud_network_subnet" "dmz_subnet" {
  network_id   = var.vpc_id
  type         = "cloud"
  network_zone = var.HCLOUD_NETWORK_ZONE
  ip_range     = var.DMZ_SUBNET_CIDR
}