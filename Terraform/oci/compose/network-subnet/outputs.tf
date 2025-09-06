#--------------------------------------------------
# Expose Subnets Information
#--------------------------------------------------
output "admin_subnet_name" {
  value = oci_core_subnet.admin_subnet.display_name
}

output "admin_subnet_id" {
  value     = oci_core_subnet.admin_subnet.id
  sensitive = true
}

output "backend_subnet_name" {
  value = oci_core_subnet.backend_subnet.display_name
}

output "backend_subnet_id" {
  value     = oci_core_subnet.backend_subnet.id
  sensitive = true
}

output "dmz_subnet_name" {
  value = oci_core_subnet.dmz_subnet.display_name
}

output "dmz_subnet_id" {
  value     = oci_core_subnet.dmz_subnet.id
  sensitive = true
}