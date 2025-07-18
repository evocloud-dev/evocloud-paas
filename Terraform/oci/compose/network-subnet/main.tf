data "oci_core_vcns" "evocloud-vpc" {
  compartment_id = local.tenancy_ocid
  display_name = var.OCI_VPC
}

resource "oci_core_subnet" "admin_subnet" {
  #Required
  cidr_block     = var.ADMIN_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id

  #Optional
  display_name = "admin_subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "backend_subnet" {
  #Required
  cidr_block     = var.BACKEND_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id

  #Optional
  display_name = "backend_subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "dmz_subnet" {
  #Required
  cidr_block     = var.DMZ_SUBNET_CIDR
  compartment_id = local.tenancy_ocid
  vcn_id         = data.oci_core_vcns.evocloud-vpc.virtual_networks[0].id

  #Optional
  display_name = "dmz_subnet"
  prohibit_public_ip_on_vnic = false
}