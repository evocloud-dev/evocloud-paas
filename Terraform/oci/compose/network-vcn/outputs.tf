#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------

output "main_vcn_id" {
  value     = oci_core_vcn.main.id
  sensitive = true
}

output "main_vcn_name" {
  value = oci_core_vcn.main.display_name
}