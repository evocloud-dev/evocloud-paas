resource "oci_core_vcn" "main" {
  #Required
  compartment_id = local.tenancy_ocid
  cidr_blocks = var.OCI_VPC_CIDR
  display_name = var.OCI_VPC
}






