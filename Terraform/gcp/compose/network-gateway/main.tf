#--------------------------------------------------
# Lookup VPC ID
#--------------------------------------------------
data "google_compute_network" "main_vpc" {
  name = var.GCP_VPC
}

#--------------------------------------------------
# Internet Gateway for VPC Internet Access
#--------------------------------------------------
resource "google_compute_router" "vpc_internet_gateway" {
  name    = "vpc-internet-gateway"
  description = "VPC Gateway Router"
  network = data.google_compute_network.main_vpc.id
}

#--------------------------------------------------
# NAT Gateway for VPC Subnets Communication
#--------------------------------------------------
resource "google_compute_router_nat" "vpc_nat_gateway" {
  name                               = "vpc-nat-gateway"
  router                             = google_compute_router.vpc_internet_gateway.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}