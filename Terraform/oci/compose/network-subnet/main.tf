resource "oci_core_subnet" "admin_subnet" {
  #Required
  cidr_block     = var.ADMIN_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "admin_subnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.private_rt_table
}

resource "oci_core_subnet" "backend_subnet" {
  #Required
  cidr_block     = var.BACKEND_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "backend_subnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.private_rt_table
}

resource "oci_core_subnet" "dmz_subnet" {
  #Required
  cidr_block     = var.DMZ_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = var.vcn_id

  #Optional
  display_name               = "dmz_subnet"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.public_rt_table
}