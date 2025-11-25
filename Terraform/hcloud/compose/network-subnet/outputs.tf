#--------------------------------------------------
# Expose Subnets Information
#--------------------------------------------------
output "admin_subnet_id" {
  value     = hcloud_network_subnet.admin_subnet.id
  sensitive = true
}

output "backend_subnet_id" {
  value     = hcloud_network_subnet.backend_subnet.id
  sensitive = true
}

output "dmz_subnet_id" {
  value     = hcloud_network_subnet.dmz_subnet.id
  sensitive = true
}