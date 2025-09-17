#--------------------------------------------------
# Internet Gateway for VPC Internet Access
#--------------------------------------------------
resource "oci_core_internet_gateway" "evocloud_inet_gateway" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  #Optional
  display_name   = "evocloud-inet-gateway"
  enabled        = true
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# NAT Gateway for VPC Private Subnets Communication
#--------------------------------------------------
resource "oci_core_nat_gateway" "evocloud_nat_gateway" {
  #Required
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  #Optional
  display_name   = "evocloud-nat-gateway"
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#------------------------------------------------------
# Service Gateway for Accessing OCI Internal Resources
#------------------------------------------------------
data "oci_core_services" "object_storage" {
  filter {
    name = "name"
    values = ["OCI .* Object Storage"]
    regex = true
  }
}

resource "oci_core_service_gateway" "oci_service_gateway" {
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  display_name   = "oci-service-gateway"

  services {
    service_id = data.oci_core_services.object_storage.services[0].id
  }
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Public Route Table for Internet Gateway
#--------------------------------------------------
resource "oci_core_route_table" "evocloud_public_rt" {
  compartment_id      = var.OCI_TENANCY_ID
  vcn_id              = var.vcn_id
  display_name        = "evocloud-public-route-table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.evocloud_inet_gateway.id
    destination       = "0.0.0.0/0" # Any traffic
  }

  route_rules {
    network_entity_id = oci_core_service_gateway.oci_service_gateway.id  # OCI Service Gateway
    destination = data.oci_core_services.object_storage.services[0].cidr_block  # OCI Services
    destination_type = "SERVICE_CIDR_BLOCK"
  }
  freeform_tags   = {"Platform"= "EvoCloud"}
}

#--------------------------------------------------
# Private Route Table for NAT Gateway
#--------------------------------------------------
resource "oci_core_route_table" "evocloud_private_rt" {
  compartment_id = var.OCI_TENANCY_ID
  vcn_id         = var.vcn_id
  display_name   = "evocloud-private-route-table"

  route_rules {
    network_entity_id = oci_core_nat_gateway.evocloud_nat_gateway.id
    destination       = "0.0.0.0/0"
  }

  route_rules {
    network_entity_id = oci_core_service_gateway.oci_service_gateway.id  # OCI Service Gateway
    destination = data.oci_core_services.object_storage.services[0].cidr_block  # OCI Services
    destination_type = "SERVICE_CIDR_BLOCK"
  }
  freeform_tags   = {"Platform"= "EvoCloud"}
}
