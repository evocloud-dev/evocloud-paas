#--------------------------------------------------
# Expose Gateway Router Information
#--------------------------------------------------
output "evocloud_internet_gateway" {
  value = oci_core_internet_gateway.evocloud_inet_gateway.display_name
}

output "evocloud_internet_gateway_id" {
  value     = oci_core_internet_gateway.evocloud_inet_gateway.id
  sensitive = true
}

output "evocloud_nat_gateway_name" {
  value = oci_core_nat_gateway.evocloud_nat_gateway.display_name
}

output "evocloud_nat_gateway_id" {
  value     = oci_core_nat_gateway.evocloud_nat_gateway.id
  sensitive = true
}

output "evocloud_public_rt" {
  value     = oci_core_route_table.evocloud_public_rt.id
  sensitive = true
}

output "evocloud_private_rt" {
  value     = oci_core_route_table.evocloud_private_rt.id
  sensitive = true
}

output "evocloud_nsg_id" {
  value     = oci_core_network_security_group.evocloud_nsg.id
  sensitive = true
}