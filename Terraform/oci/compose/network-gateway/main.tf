#--------------------------------------------------
# Lookup VPC ID
#--------------------------------------------------
data "oci_core_vcns" "evocloud-vpc" {
  compartment_id = local.tenancy_ocid
  display_name = var.OCI_VPC
}

data "oci_core_route_tables" "evocloud_route_tables" {
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id
}

#--------------------------------------------------
# Internet Gateway for VPC Internet Access
#--------------------------------------------------
resource "oci_core_internet_gateway" "evocloud_internet_gateway" {
  #Required
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id

  #Optional
  display_name    = "evocloud-internet-gateway"
  enabled         = true
}

#--------------------------------------------------
# NAT Gateway for VPC Subnets Communication
#--------------------------------------------------
resource "oci_core_nat_gateway" "evocloud_nat_gateway" {
  #Required
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id

  #Optional
  display_name   = "evocloud-nat-gateway"
  route_table_id = data.oci_core_route_tables.evocloud_route_tables.id
}