#--------------------------------------------------
# Expose Route Table IDs
#--------------------------------------------------

output "public_route_table" {
  value   = oci_core_route_table.evocloud_public_rt.id
}

output "private_route_table" {
  value   = oci_core_route_table.evocloud_private_rt.id
}