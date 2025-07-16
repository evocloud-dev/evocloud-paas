resource "oci_core_vcn" "main" {
  #Required
  compartment_id = var.OCI_PROJECT_ID
  cidr_blocks = var.OCI_VPC_CIDR
  display_name = var.OCI_VPC
}