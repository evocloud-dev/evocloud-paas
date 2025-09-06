#-------------------------------
# VCN Network Resource
#-------------------------------
resource "oci_core_vcn" "main" {
  compartment_id  = var.OCI_TENANCY_ID
  cidr_blocks     = var.OCI_VPC_CIDR
  display_name    = var.OCI_VPC
  freeform_tags   = {"Platform"= "EvoCloud"}
}