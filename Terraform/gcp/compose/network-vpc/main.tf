#-------------------------------
# VPC Network Resource
#-------------------------------
resource "google_compute_network" "main" {
  name = var.GCP_VPC
  description = "Evocloud Main VPC"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
}


#-------------------------------
# Firewall Security Rules
#-------------------------------
# Allow Ingress SSH on all IPs
resource "google_compute_firewall" "firewall_rules_ingress_ssh" {
  name        = "vpc-main-firewall-ssh-allow"
  description = "Allow ssh traffic on Main VPC"
  network     = google_compute_network.main.name
  direction   = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

# Allow Ingress Common Core Rules
resource "google_compute_firewall" "firewall_rules_ingress_common" {
  name        = "vpc-main-firewall-common-allow"
  description = "Allow common core traffic on Main VPC"
  network     = google_compute_network.main.name
  direction   = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["6443"]
  }
  allow {
    protocol = "tcp"
    ports = ["50000"]
  }
  allow {
    protocol = "tcp"
    ports = ["50001"]
  }
}

# Allow Ingress traffic on all internal IPs
resource "google_compute_firewall" "firewall_rules_ingress_internal" {
  name        = "vpc-main-firewall-internal-allow"
  description = "Allow internal traffic on Main VPC"
  network     = google_compute_network.main.name
  direction   = "INGRESS"
  source_ranges = ["${var.DMZ_SUBNET_CIDR}", "${var.ADMIN_SUBNET_CIDR}", "${var.BACKEND_SUBNET_CIDR}", "${var.ADMIN_SUBNET_CIDR_LBIPAM}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }
}

# Begin - Setup for forwarding DNS Request to EvoCloud IDAM Servers
#----------------------------------------
# DNS Managed Zone - Private Forwarding
#----------------------------------------
#resource "google_dns_managed_zone" "evodns_zone" {
#  name        = "evodns-zone"
#  dns_name    = "${var.DOMAIN_TLD}."
#  description = "EvoCloud private DNS zone"
#  visibility = "private"

#  private_visibility_config {
#    networks {
#      network_url = google_compute_network.main.id
#    }
#  }

#  forwarding_config {
#    target_name_servers {
#      ipv4_address = var.IDAM_PRIVATE_IP
#      forwarding_path = "private" #default | private
#    }
#    target_name_servers {
#      ipv4_address = var.IDAM_REPLICA_PRIVATE_IP
#      forwarding_path = "private" #default | private
#    }
#  }
#}
#----------------------------------
# Custom DNS Policy Reference
#----------------------------------
#resource "google_dns_policy" "evodns_policy" {
#  name = "evodns-outbound-policy"
#  description = "EvoCloud Outbound Policy to EvoDNS Zone"
#  enable_inbound_forwarding = false

#  alternative_name_server_config {
#    target_name_servers {
#      ipv4_address    = var.IDAM_PRIVATE_IP
#      forwarding_path = "private" #default | private
#    }
#    target_name_servers {
#      ipv4_address    = var.IDAM_REPLICA_PRIVATE_IP
#      forwarding_path = "private" #default | private
#    }
#  }

#  networks {
#    network_url = google_compute_network.main.id
#  }
#}
# End - Setup for referencing EvoCloud Private DNS