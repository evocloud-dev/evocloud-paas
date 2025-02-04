#--------------------------------------------------
# Lookup VPC ID
#--------------------------------------------------
data "google_compute_network" "main_vpc" {
  name = var.GCP_VPC
}

#--------------------------------------------------
# Create DMZ Subnet in all Availability Zones
#--------------------------------------------------
resource "google_compute_subnetwork" "dmz_subnet" {
  name              = "dmz-subnet"
  description       = "DMZ Subnetwork"
  ip_cidr_range     = var.DMZ_SUBNET_CIDR
  network           = data.google_compute_network.main_vpc.id
  private_ip_google_access = true
}

#--------------------------------------------------
# Create ADMIN Subnet in all Availability Zones
#--------------------------------------------------
resource "google_compute_subnetwork" "admin_subnet" {
  name              = "admin-subnet"
  description       = "ADMIN Subnetwork"
  ip_cidr_range     = var.ADMIN_SUBNET_CIDR
  network           = data.google_compute_network.main_vpc.id
  private_ip_google_access = true
}

#--------------------------------------------------
# Create BACKEND Subnet in all Availability Zones
#--------------------------------------------------
resource "google_compute_subnetwork" "backend_subnet" {
  name              = "backend-subnet"
  description       = "BACKEND Subnetwork"
  ip_cidr_range     = var.BACKEND_SUBNET_CIDR
  network           = data.google_compute_network.main_vpc.id
  private_ip_google_access = true
}