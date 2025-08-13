#--------------------------------------------------
# Expose Subnet Information
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

#--------------------------------------------------
# Expose Security List Information
#--------------------------------------------------
output "dmz_seclist_name" {
  value = oci_core_security_list.dmz_list.display_name
}

output "dmz_seclist_id" {
  value = oci_core_security_list.dmz_list.id
}

output "private_seclist_name" {
  value = oci_core_security_list.private_subnet_list.display_name
}

output "private_seclist_id" {
  value = oci_core_security_list.private_subnet_list.id
}