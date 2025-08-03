#--------------------------------------------------
# Expose Main VPC ID
#--------------------------------------------------

output "main_vpc_id" {
  value     = oci_core_vcn.main.id
  sensitive = true
}

output "main_vpc_name" {
  value = oci_core_vcn.main.display_name
}